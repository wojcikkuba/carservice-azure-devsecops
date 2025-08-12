import React from 'react';
import { BrowserRouter, Routes, Route } from 'react-router-dom';
import CarList from './components/CarList';
import AddCarForm from './components/AddCarForm';
import CarDetails from './components/CarDetails';
import AddRepairForm from './components/AddRepairForm';
import Navbar from './components/NavBar';

function App() {
  return (
    <BrowserRouter>
        <Navbar />
        <div style={{padding: '1rem'}}>
        <Routes>

        <Route path="/" element={<CarList />} />
        <Route path="/add" element={<AddCarForm />} />
        <Route path="/cars/:id" element={<CarDetails />} />
        <Route path="/cars/:id/repairs/add" element={<AddRepairForm />} />
      </Routes>
      </div>
    </BrowserRouter>
  );
}

export default App;

//=====TEST=====

// import React from 'react';

// function App() {
//   console.log("✅ Frontend działa – React uruchomiony!");

//   return (
//     <div style={{ textAlign: 'center', marginTop: '5rem' }}>
//       <h1>🚗 CarServiceTracker działa!</h1>
//       <p>Frontend działa poprawnie z Kubernetesa 🎉</p>
//     </div>
//   );
// }

// export default App;

