import React from 'react';
import { Link } from 'react-router-dom';
import './NavBar.css'; // Będzie za chwilę

const Navbar = () => {
  return (
    <nav className="navbar">
      <h1 className="navbar-title">Car Service Tracker</h1>
      <div className="navbar-links">
        <Link to="/">Lista samochodów</Link>
        <Link to="/add">Dodaj samochód</Link>
      </div>
    </nav>
  );
};

export default Navbar;