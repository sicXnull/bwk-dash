
const img = require('../img/whitelogo.svg');
const React = require('react');

const Logo = (props) => (
  <div className="logo responsive-img">
    <img
      alt="POSQ Home Node Dashboard"
      src={ img }
      title="POSQ Home Node Dashboard" />
  </div>
);

module.exports = Logo;
