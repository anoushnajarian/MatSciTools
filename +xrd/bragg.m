function d = bragg(two_theta, varargin)
%XRD.BRAGG Compute d-spacing from Bragg's law
%   D = XRD.BRAGG(TWO_THETA) computes interplanar d-spacing in Angstroms
%   using Bragg's law: d = lambda / (2 * sin(theta)).
%
%   TWO_THETA is in degrees. D is returned in Angstroms.
%
%   Optional Parameters:
%     'Wavelength' - X-ray wavelength in Angstroms (default: 1.5406, Cu Ka)
%
%   Example:
%     d = xrd.bragg([38.5, 44.7, 65.1, 78.2]);
%     fprintf('d-spacings: '); fprintf('%.4f ', d); fprintf('Angstroms\n');

    p = inputParser;
    addRequired(p, 'two_theta', @isnumeric);
    addParameter(p, 'Wavelength', 1.5406, @isnumeric);
    parse(p, two_theta, varargin{:});

    lambda = p.Results.Wavelength;

    theta_rad = (two_theta / 2) * pi / 180;
    d = lambda ./ (2 * sin(theta_rad));
end
