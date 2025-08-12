import React, { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import './CarList.css'; // Dodajemy styl!

const CarList = () => {
  const [cars, setCars] = useState([]);

  useEffect(() => {
    fetch('https://cartrack-backend-app.azurewebsites.net/api/cars')
      .then((res) => res.json())
      .then((data) => setCars(data))
      .catch((err) => console.error('Błąd pobierania samochodów:', err));
  }, []);

  return (
    <div className="car-list-container">
      <div className="car-list-header">
        <h2>Lista samochodów</h2>
        <Link to="/add">
          <button className="add-button">Dodaj samochód</button>
        </Link>
      </div>

      <table className="car-table">
        <thead>
          <tr>
            <th>ID</th>
            <th>Marka</th>
            <th>Model</th>
            <th>Rok</th>
            <th>VIN</th>
          </tr>
        </thead>
        <tbody>
          {cars.map((car) => (
            <tr key={car.id}>
              <td>
                <Link to={`/cars/${car.id}`}>{car.id}</Link>
              </td>
              <td>
                <Link to={`/cars/${car.id}`}>{car.make}</Link>
              </td>
              <td>{car.model}</td>
              <td>{car.year}</td>
              <td>{car.vin}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
};

export default CarList;