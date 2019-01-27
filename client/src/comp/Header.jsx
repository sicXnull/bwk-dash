
const React = require('react');

const Logo = require('../ui/Logo');

const Header = () => (
  <div className="header">
    <div className="bx--grid">
      <div className="bx--row">
        <div className="bx--col-sm-12 bx--col-md-2">
          <Logo />
        </div>
        <div className="bx--col-sm-12 bx--col-md-4 bx--type-beta">
          Home Node Dashboard
        </div>
        <div className="bx--col-sm-12 bx--col-md-6" style={{ textAlign: 'right' }}>
          <a
            className="rectangle-2"
            href="https://github.com/Poseidon-POSQ"
            target="_blank">
            Help
          </a>
          <a
            className="rectangle-2"
            href="https://posq.space/explorer"
            target="_blank">
            Block Explorer
          </a>
          <a
            className="rectangle-2"
            href="https://github.com/Poseidon-POSQ"
            target="_blank">
            GitHub
          </a>
        </div>
      </div>
    </div>
  </div>
);

module.exports = Header;
