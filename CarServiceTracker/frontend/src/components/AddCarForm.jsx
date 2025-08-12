import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import './Form.css'; // 👈 Nowy plik CSS!

const API = 'https://cartrack-backend-app.azurewebsites.net/api';

const AddCarForm = () => {
  const [car, setCar] = useState({ make: '', model: '', year: '', vin: '' });
  const navigate = useNavigate();

  const handleChange = (e) => {
    setCar({ ...car, [e.target.name]: e.target.value });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    await fetch(`${API}/cars`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(car),
    });
    navigate('/');
  };

  return (
    <form onSubmit={handleSubmit} className="form-container">
      <h2>Dodaj samochód</h2>
      <input name="make" placeholder="Marka" onChange={handleChange} required />
      <input name="model" placeholder="Model" onChange={handleChange} required />
      <input name="year" placeholder="Rok" type="number" onChange={handleChange} required />
      <input name="vin" placeholder="VIN" onChange={handleChange} required />
      <button type="submit">Zapisz</button>
    </form>
  );
};

export default AddCarForm;