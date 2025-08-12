// server.js
const express = require('express');
const dotenv = require('dotenv');
const pool = require('./db');

dotenv.config();
const app = express();
app.use(express.json());
// Podstawowy CORS - "niebezpieczny" ale działający
app.use((req, res, next) => {
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Headers', '*');
  res.header('Access-Control-Allow-Methods', '*');
  if (req.method === 'OPTIONS') {
    res.sendStatus(200);
  } else {
    next();
  }
});

// GET /cars – lista wszystkich samochodów
app.get('/api/cars', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM cars ORDER BY id ASC');
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).send('Błąd serwera');
  }
});

// POST /cars – dodaj nowy samochód
app.post('/api/cars', async (req, res) => {
  const { make, model, year, vin } = req.body;
  try {
    const result = await pool.query(
      'INSERT INTO cars (make, model, year, vin) VALUES ($1, $2, $3, $4) RETURNING *',
      [make, model, year, vin]
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).send('Błąd serwera');
  }
});

// DELETE /cars/:id – usuń samochód
app.delete('/api/cars/:id', async (req, res) => {
  const { id } = req.params;
  try {
    await pool.query('DELETE FROM cars WHERE id = $1', [id]);
    res.status(204).send();
  } catch (err) {
    console.error(err);
    res.status(500).send('Błąd serwera');
  }
});

// PUT /cars/:id – edytuj samochód
app.put('/api/cars/:id', async (req, res) => {
  const { id } = req.params;
  const { make, model, year, vin } = req.body;
  try {
    const result = await pool.query(
      'UPDATE cars SET make = $1, model = $2, year = $3, vin = $4 WHERE id = $5 RETURNING *',
      [make, model, year, vin, id]
    );
    res.json(result.rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).send('Błąd serwera');
  }
});

// GET /cars/:id/repairs – lista napraw auta
app.get('/api/cars/:id/repairs', async (req, res) => {
  const { id } = req.params;
  try {
    const result = await pool.query(
      'SELECT * FROM repairs WHERE car_id = $1 ORDER BY date DESC',
      [id]
    );
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).send('Błąd pobierania napraw');
  }
});

// GET /cars/:id – szczegóły samochodu + naprawy
app.get('/api/cars/:id', async (req, res) => {
  const { id } = req.params;

  try {
    const carResult = await pool.query('SELECT * FROM cars WHERE id = $1', [id]);
    if (carResult.rows.length === 0) {
      return res.status(404).send('Samochód nie znaleziony');
    }

    const repairResult = await pool.query(
      'SELECT * FROM repairs WHERE car_id = $1 ORDER BY date DESC',
      [id]
    );

    const car = carResult.rows[0];
    car.repairs = repairResult.rows;

    res.json(car);
  } catch (err) {
    console.error(err);
    res.status(500).send('Błąd pobierania szczegółów samochodu');
  }
});


// POST /cars/:id/repairs – dodaj naprawę do auta
app.post('/api/cars/:id/repairs', async (req, res) => {
  const { id } = req.params;
  const { description, date, cost } = req.body;
  try {
    const result = await pool.query(
      'INSERT INTO repairs (car_id, description, date, cost) VALUES ($1, $2, $3, $4) RETURNING *',
      [id, description, date || new Date(), cost]
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).send('Błąd dodawania naprawy');
  }
});

// GET /cars/:id/services – przeglądy danego samochodu
app.get('/api/cars/:id/services', async (req, res) => {
  const { id } = req.params;
  try {
    const result = await pool.query(
      'SELECT * FROM services WHERE car_id = $1 ORDER BY date DESC',
      [id]
    );
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).send('Błąd serwera');
  }
});

// POST /cars/:id/services – dodaj przegląd
app.post('/api/cars/:id/services', async (req, res) => {
  const { id } = req.params;
  const { description, cost, date, status } = req.body;

  try {
    const result = await pool.query(
      'INSERT INTO services (car_id, description, cost, date, status) VALUES ($1, $2, $3, $4, $5) RETURNING *',
      [id, description, cost, date || new Date(), status || 'done']
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).send('Błąd serwera');
  }
});

// Start
const PORT = process.env.PORT || 3000;
app.listen(PORT, '0.0.0.0', () => console.log(`Backend działa na porcie ${PORT}`));

