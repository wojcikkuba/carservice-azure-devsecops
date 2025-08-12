import React, { useEffect, useState } from 'react';
import { useParams, Link } from 'react-router-dom';
import './CarDetails.css';

const API = 'https://cartrack-backend-app.azurewebsites.net/api';

const CarDetails = () => {
  const { id } = useParams();
  const [car, setCar] = useState(null);

  useEffect(() => {
    fetch(`${API}/cars/${id}`)
      .then((res) => res.json())
      .then((data) => setCar(data))
      .catch((err) => console.error('Błąd:', err));
  }, [id]);

  if (!car) return <div>Ładowanie...</div>;

  return (
    <div className="car-details">
      <h2>{car.make} {car.model} ({car.year})</h2>
      <p><strong>VIN:</strong> {car.vin}</p>

      <Link to={`/cars/${car.id}/repairs/add`}>
        <button className="add-repair-button">Dodaj wpis serwisowy</button>
      </Link>

      <h3>Historia serwisowa</h3>
      {car.repairs && car.repairs.length > 0 ? (
        <table>
          <thead>
            <tr>
              <th>Data</th>
              <th>Opis</th>
              <th>Koszt</th>
            </tr>
          </thead>
          <tbody>
            {car.repairs.map(r => (
              <tr key={r.id}>
                <td>{r.date}</td>
                <td>{r.description}</td>
                <td>{r.cost} zł</td>
              </tr>
            ))}
          </tbody>
        </table>
      ) : (
        <p>Brak historii serwisowej.</p>
      )}

      <Link to="/">
        <button className="back-button">← Powrót do listy</button>
      </Link>
    </div>
  );
};

export default CarDetails;
