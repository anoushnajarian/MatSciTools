function [true_strain, true_stress] = true_stress_strain(eng_strain, eng_stress)
%MECHTEST.TRUE_STRESS_STRAIN Convert engineering to true stress-strain
%   [TRUE_STRAIN, TRUE_STRESS] = MECHTEST.TRUE_STRESS_STRAIN(ENG_STRAIN, ENG_STRESS)
%   converts engineering stress-strain data to true stress-strain.
%
%   Equations (valid up to necking/UTS):
%     true_strain = ln(1 + eng_strain)
%     true_stress = eng_stress * (1 + eng_strain)
%
%   Data beyond UTS is flagged with a warning since the conversion is only
%   valid for uniform deformation (pre-necking).
%
%   Inputs:
%     ENG_STRAIN - Engineering strain (mm/mm)
%     ENG_STRESS - Engineering stress (MPa)
%
%   Outputs:
%     TRUE_STRAIN - True (logarithmic) strain
%     TRUE_STRESS - True stress (MPa)
%
%   Example:
%     [strain, stress] = mechtest.generate_sample('steel');
%     [ts, tt] = mechtest.true_stress_strain(strain, stress);

    eng_strain = eng_strain(:);
    eng_stress = eng_stress(:);

    if numel(eng_strain) ~= numel(eng_stress)
        error('mechtest:SizeMismatch', 'Strain and stress vectors must have the same length.');
    end

    % Find UTS index (conversion only valid up to UTS)
    [~, uts_idx] = max(eng_stress);

    if uts_idx < numel(eng_stress)
        warning('mechtest:PostNecking', ...
            'Data extends beyond UTS (point %d of %d). True stress-strain conversion is only valid up to UTS (uniform deformation). Post-UTS data is included but may be inaccurate.', ...
            uts_idx, numel(eng_stress));
    end

    true_strain = log(1 + eng_strain);
    true_stress = eng_stress .* (1 + eng_strain);
end
