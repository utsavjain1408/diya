// src/App.jsx
import { useState, useEffect } from 'react';
import './App.css';

function App() {
  const [records, setRecords] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  // IMPORTANT: Replace with a valid API key for your API.
  // You can create one using the Tyk Gateway API.
  const API_KEY = 'YOUR_API_KEY_HERE'; 

  useEffect(() => {
    const fetchRecords = async () => {
      try {
        const response = await fetch('http://localhost:8087/api/records', {
          headers: {
            'Authorization': API_KEY,
          },
        });

        if (!response.ok) {
          throw new Error(`HTTP error! status: ${response.status}`);
        }

        const data = await response.json();
        setRecords(data);
      } catch (e) {
        setError(e.message);
      } finally {
        setLoading(false);
      }
    };

    fetchRecords();
  }, []); // Empty dependency array means this effect runs once on mount

  return (
    <>
      <h1>Data Records</h1>
      {loading && <p>Loading...</p>}
      {error && <p>Error fetching data: {error}</p>}
      <ul>
        {records && records.map((record) => (
          <li key={record.ID}>
            <strong>ID {record.ID}:</strong> {record.Data} (Created: {new Date(record.CreatedAt).toLocaleString()})
          </li>
        ))}
      </ul>
    </>
  );
}

export default App;
