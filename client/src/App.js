import React from 'react';
import { BrowserRouter as Router, Route, Routes } from 'react-router-dom';

function App() {
  return (
    <Router>
      <div className="App">
        <h1>Welcome to Pmemo</h1>
        <Routes>
          <Route path="/" element={<Home />} />
          {/* 其他路由可以在这里添加 */}
        </Routes>
      </div>
    </Router>
  );
}

function Home() {
  return <h2>Home Page</h2>;
}

export default App; 