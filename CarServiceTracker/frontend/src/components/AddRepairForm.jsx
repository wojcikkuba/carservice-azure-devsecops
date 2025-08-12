import React, { useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import './Form.css'; // Wspólny CSS dla formularzy

const API = 'https://cartrack-backend-app.azurewebsites.net/api';

const AddRepairForm = () => {
  const { id } = useParams();
  const [repair, setRepair] = useState({ date: '', description: '', cost: '' });
  const navigate = useNavigate();

  const handleChange = (e) => {
    setRepair({ ...repair, [e.target.name]: e.target.value });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    await fetch(`${API}/cars/${id}/repairs`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(repair),
    });
    navigate(`/cars/${id}`);
  };

  return (
    <form onSubmit={handleSubmit} className="form-container">
      <h2>Dodaj wpis serwisowy</h2>
      <input name="date" type="date" onChange={handleChange} required />
      <input name="description" placeholder="Opis" onChange={handleChange} required />
      <input name="cost" type="number" placeholder="Koszt" onChange={handleChange} required />
      <button type="submit">Zapisz</button>
    </form>
  );
};

export default AddRepairForm;