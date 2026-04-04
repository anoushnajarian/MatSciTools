function info = systems()
%PHASEDIAG.SYSTEMS List available binary phase diagram systems
%   INFO = PHASEDIAG.SYSTEMS() returns a table of available systems.
%
%   Example:
%     info = phasediag.systems();
%     disp(info);

    names = {'Cu-Ni'; 'Pb-Sn'; 'Al-Si'; 'Al-Cu'; 'Fe-Ni'; 'custom'};
    types = {'Isomorphous'; 'Eutectic-like'; 'Eutectic-like'; 'Peritectic-like'; 'Isomorphous'; 'User-defined'};
    descriptions = {
        'Complete solid solubility (ideal solution)'
        'Lead-tin system with limited solubility'
        'Aluminum-silicon eutectic system'
        'Aluminum-copper with intermetallics (simplified)'
        'Iron-nickel isomorphous system'
        'User-defined Tm_A, Tm_B, Hf_A, Hf_B, Omega'
    };

    info = table(names, types, descriptions, ...
        'VariableNames', {'System', 'Type', 'Description'});
end
