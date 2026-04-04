function matscitools()
%MATSCITOOLS Material Science Engineering Toolkit for MATLAB
%   MATSCITOOLS displays information about the toolkit and available modules.
%
%   Modules:
%     matdb          - Material property database (57 materials)
%     matsel         - Material selection (Ashby charts)
%     mechtest       - Mechanical testing analysis
%     phasediag      - Phase diagram computation
%     microstructure - Microstructure image analysis
%     intelligence   - ML prediction & material recommendation
%     xrd            - X-ray diffraction analysis
%     gui            - Interactive GUI application
%
%   Example:
%     matscitools()
%     materials = matdb.list();
%     matsel.ashby('density', 'youngs_modulus');

    fprintf('\n');
    fprintf('  MatSciTools - Material Science Engineering Toolkit\n');
    fprintf('  Version 1.0\n');
    fprintf('  ================================================\n\n');
    fprintf('  Available Modules:\n');
    fprintf('    matdb          - Material property database (57 materials)\n');
    fprintf('    matsel         - Material selection (Ashby charts)\n');
    fprintf('    mechtest       - Mechanical testing analysis\n');
    fprintf('    phasediag      - Phase diagram computation\n');
    fprintf('    microstructure - Microstructure image analysis\n');
    fprintf('    intelligence   - ML prediction, clustering & anomaly detection\n');
    fprintf('    xrd            - X-ray diffraction analysis\n');
    fprintf('    gui            - Interactive GUI application\n');
    fprintf('\n');
    fprintf('  Quick Start:\n');
    fprintf('    materials = matdb.list();           %% List all materials\n');
    fprintf('    steel = matdb.get(''AISI 1045'');     %% Get material properties\n');
    fprintf('    matsel.ashby(''density'', ''youngs_modulus''); %% Ashby chart\n');
    fprintf('    matsel.convert_units(200, ''MPa'', ''ksi'');  %% Unit conversion\n');
    fprintf('    results = mechtest.analyze(data);   %% Analyze stress-strain\n');
    fprintf('    phasediag.plot(''Cu-Ni'');             %% Phase diagram\n');
    fprintf('    pred = intelligence.predict_properties(''Al 6061-T6''); %% ML prediction\n');
    fprintf('    clusters = intelligence.cluster_materials(''K'', 5);    %% Material clustering\n');
    fprintf('    app = gui.MatSciApp();               %% Launch GUI\n');
    fprintf('\n');
end
