function db = load_database()
%LOAD_DATABASE Load the built-in material property database
%   Returns a struct array with material properties.

    db = struct();
    idx = 0;

    % --- Metals ---
    idx=idx+1; db(idx).name='AISI 1020 Steel'; db(idx).category='Metal'; db(idx).subcategory='Carbon Steel';
    db(idx).density=7870; db(idx).youngs_modulus=200; db(idx).yield_strength=350; db(idx).uts=420;
    db(idx).elongation=25; db(idx).hardness=120; db(idx).thermal_conductivity=51.9;
    db(idx).thermal_expansion=11.7; db(idx).melting_point=1515; db(idx).poissons_ratio=0.29;
    db(idx).cost=0.5; db(idx).specific_heat=486;

    idx=idx+1; db(idx).name='AISI 1045 Steel'; db(idx).category='Metal'; db(idx).subcategory='Carbon Steel';
    db(idx).density=7850; db(idx).youngs_modulus=206; db(idx).yield_strength=530; db(idx).uts=625;
    db(idx).elongation=16; db(idx).hardness=179; db(idx).thermal_conductivity=49.8;
    db(idx).thermal_expansion=11.2; db(idx).melting_point=1510; db(idx).poissons_ratio=0.29;
    db(idx).cost=0.6; db(idx).specific_heat=486;

    idx=idx+1; db(idx).name='AISI 304 Stainless Steel'; db(idx).category='Metal'; db(idx).subcategory='Stainless Steel';
    db(idx).density=8000; db(idx).youngs_modulus=193; db(idx).yield_strength=215; db(idx).uts=505;
    db(idx).elongation=70; db(idx).hardness=123; db(idx).thermal_conductivity=16.2;
    db(idx).thermal_expansion=17.3; db(idx).melting_point=1450; db(idx).poissons_ratio=0.29;
    db(idx).cost=2.5; db(idx).specific_heat=500;

    idx=idx+1; db(idx).name='AISI 316 Stainless Steel'; db(idx).category='Metal'; db(idx).subcategory='Stainless Steel';
    db(idx).density=8000; db(idx).youngs_modulus=193; db(idx).yield_strength=205; db(idx).uts=515;
    db(idx).elongation=60; db(idx).hardness=149; db(idx).thermal_conductivity=16.3;
    db(idx).thermal_expansion=15.9; db(idx).melting_point=1400; db(idx).poissons_ratio=0.27;
    db(idx).cost=3.5; db(idx).specific_heat=500;

    idx=idx+1; db(idx).name='Al 6061-T6'; db(idx).category='Metal'; db(idx).subcategory='Aluminum Alloy';
    db(idx).density=2700; db(idx).youngs_modulus=68.9; db(idx).yield_strength=276; db(idx).uts=310;
    db(idx).elongation=12; db(idx).hardness=95; db(idx).thermal_conductivity=167;
    db(idx).thermal_expansion=23.6; db(idx).melting_point=652; db(idx).poissons_ratio=0.33;
    db(idx).cost=2.0; db(idx).specific_heat=896;

    idx=idx+1; db(idx).name='Al 7075-T6'; db(idx).category='Metal'; db(idx).subcategory='Aluminum Alloy';
    db(idx).density=2810; db(idx).youngs_modulus=71.7; db(idx).yield_strength=503; db(idx).uts=572;
    db(idx).elongation=11; db(idx).hardness=150; db(idx).thermal_conductivity=130;
    db(idx).thermal_expansion=23.4; db(idx).melting_point=635; db(idx).poissons_ratio=0.33;
    db(idx).cost=3.0; db(idx).specific_heat=960;

    idx=idx+1; db(idx).name='Al 2024-T3'; db(idx).category='Metal'; db(idx).subcategory='Aluminum Alloy';
    db(idx).density=2780; db(idx).youngs_modulus=73.1; db(idx).yield_strength=345; db(idx).uts=483;
    db(idx).elongation=18; db(idx).hardness=120; db(idx).thermal_conductivity=121;
    db(idx).thermal_expansion=23.2; db(idx).melting_point=638; db(idx).poissons_ratio=0.33;
    db(idx).cost=2.8; db(idx).specific_heat=875;

    idx=idx+1; db(idx).name='Ti-6Al-4V'; db(idx).category='Metal'; db(idx).subcategory='Titanium Alloy';
    db(idx).density=4430; db(idx).youngs_modulus=113.8; db(idx).yield_strength=880; db(idx).uts=950;
    db(idx).elongation=14; db(idx).hardness=334; db(idx).thermal_conductivity=6.7;
    db(idx).thermal_expansion=8.6; db(idx).melting_point=1660; db(idx).poissons_ratio=0.34;
    db(idx).cost=25.0; db(idx).specific_heat=526;

    idx=idx+1; db(idx).name='Pure Copper'; db(idx).category='Metal'; db(idx).subcategory='Copper';
    db(idx).density=8960; db(idx).youngs_modulus=117; db(idx).yield_strength=70; db(idx).uts=220;
    db(idx).elongation=60; db(idx).hardness=50; db(idx).thermal_conductivity=401;
    db(idx).thermal_expansion=16.5; db(idx).melting_point=1085; db(idx).poissons_ratio=0.34;
    db(idx).cost=6.0; db(idx).specific_heat=385;

    idx=idx+1; db(idx).name='Brass C360'; db(idx).category='Metal'; db(idx).subcategory='Copper Alloy';
    db(idx).density=8500; db(idx).youngs_modulus=97; db(idx).yield_strength=310; db(idx).uts=385;
    db(idx).elongation=25; db(idx).hardness=80; db(idx).thermal_conductivity=115;
    db(idx).thermal_expansion=20.5; db(idx).melting_point=900; db(idx).poissons_ratio=0.34;
    db(idx).cost=4.0; db(idx).specific_heat=380;

    idx=idx+1; db(idx).name='Inconel 718'; db(idx).category='Metal'; db(idx).subcategory='Nickel Superalloy';
    db(idx).density=8190; db(idx).youngs_modulus=200; db(idx).yield_strength=1034; db(idx).uts=1241;
    db(idx).elongation=12; db(idx).hardness=331; db(idx).thermal_conductivity=11.4;
    db(idx).thermal_expansion=13.0; db(idx).melting_point=1336; db(idx).poissons_ratio=0.29;
    db(idx).cost=30.0; db(idx).specific_heat=435;

    idx=idx+1; db(idx).name='Magnesium AZ31B'; db(idx).category='Metal'; db(idx).subcategory='Magnesium Alloy';
    db(idx).density=1770; db(idx).youngs_modulus=45; db(idx).yield_strength=220; db(idx).uts=290;
    db(idx).elongation=15; db(idx).hardness=73; db(idx).thermal_conductivity=96;
    db(idx).thermal_expansion=26.0; db(idx).melting_point=630; db(idx).poissons_ratio=0.35;
    db(idx).cost=3.5; db(idx).specific_heat=1024;

    % --- Ceramics ---
    idx=idx+1; db(idx).name='Alumina (Al2O3)'; db(idx).category='Ceramic'; db(idx).subcategory='Oxide Ceramic';
    db(idx).density=3950; db(idx).youngs_modulus=370; db(idx).yield_strength=2100; db(idx).uts=300;
    db(idx).elongation=0; db(idx).hardness=1500; db(idx).thermal_conductivity=35;
    db(idx).thermal_expansion=8.1; db(idx).melting_point=2072; db(idx).poissons_ratio=0.22;
    db(idx).cost=5.0; db(idx).specific_heat=880;

    idx=idx+1; db(idx).name='Silicon Carbide (SiC)'; db(idx).category='Ceramic'; db(idx).subcategory='Carbide Ceramic';
    db(idx).density=3100; db(idx).youngs_modulus=410; db(idx).yield_strength=3900; db(idx).uts=550;
    db(idx).elongation=0; db(idx).hardness=2800; db(idx).thermal_conductivity=120;
    db(idx).thermal_expansion=4.0; db(idx).melting_point=2730; db(idx).poissons_ratio=0.17;
    db(idx).cost=15.0; db(idx).specific_heat=750;

    idx=idx+1; db(idx).name='Silicon Nitride (Si3N4)'; db(idx).category='Ceramic'; db(idx).subcategory='Nitride Ceramic';
    db(idx).density=3200; db(idx).youngs_modulus=310; db(idx).yield_strength=3000; db(idx).uts=700;
    db(idx).elongation=0; db(idx).hardness=1800; db(idx).thermal_conductivity=30;
    db(idx).thermal_expansion=3.3; db(idx).melting_point=1900; db(idx).poissons_ratio=0.27;
    db(idx).cost=20.0; db(idx).specific_heat=680;

    idx=idx+1; db(idx).name='Zirconia (ZrO2)'; db(idx).category='Ceramic'; db(idx).subcategory='Oxide Ceramic';
    db(idx).density=6000; db(idx).youngs_modulus=200; db(idx).yield_strength=2000; db(idx).uts=400;
    db(idx).elongation=0; db(idx).hardness=1200; db(idx).thermal_conductivity=2;
    db(idx).thermal_expansion=10.5; db(idx).melting_point=2715; db(idx).poissons_ratio=0.31;
    db(idx).cost=25.0; db(idx).specific_heat=460;

    idx=idx+1; db(idx).name='Borosilicate Glass'; db(idx).category='Ceramic'; db(idx).subcategory='Glass';
    db(idx).density=2230; db(idx).youngs_modulus=63; db(idx).yield_strength=280; db(idx).uts=70;
    db(idx).elongation=0; db(idx).hardness=418; db(idx).thermal_conductivity=1.14;
    db(idx).thermal_expansion=3.3; db(idx).melting_point=820; db(idx).poissons_ratio=0.2;
    db(idx).cost=2.0; db(idx).specific_heat=830;

    % --- Polymers ---
    idx=idx+1; db(idx).name='HDPE'; db(idx).category='Polymer'; db(idx).subcategory='Thermoplastic';
    db(idx).density=960; db(idx).youngs_modulus=1.1; db(idx).yield_strength=26; db(idx).uts=33;
    db(idx).elongation=500; db(idx).hardness=6; db(idx).thermal_conductivity=0.44;
    db(idx).thermal_expansion=100; db(idx).melting_point=130; db(idx).poissons_ratio=0.46;
    db(idx).cost=1.0; db(idx).specific_heat=1900;

    idx=idx+1; db(idx).name='Polypropylene (PP)'; db(idx).category='Polymer'; db(idx).subcategory='Thermoplastic';
    db(idx).density=905; db(idx).youngs_modulus=1.5; db(idx).yield_strength=35; db(idx).uts=40;
    db(idx).elongation=400; db(idx).hardness=9; db(idx).thermal_conductivity=0.12;
    db(idx).thermal_expansion=100; db(idx).melting_point=165; db(idx).poissons_ratio=0.43;
    db(idx).cost=1.2; db(idx).specific_heat=1920;

    idx=idx+1; db(idx).name='Nylon 6,6'; db(idx).category='Polymer'; db(idx).subcategory='Thermoplastic';
    db(idx).density=1140; db(idx).youngs_modulus=3.3; db(idx).yield_strength=70; db(idx).uts=85;
    db(idx).elongation=60; db(idx).hardness=12; db(idx).thermal_conductivity=0.25;
    db(idx).thermal_expansion=80; db(idx).melting_point=264; db(idx).poissons_ratio=0.39;
    db(idx).cost=3.0; db(idx).specific_heat=1670;

    idx=idx+1; db(idx).name='Polycarbonate (PC)'; db(idx).category='Polymer'; db(idx).subcategory='Thermoplastic';
    db(idx).density=1200; db(idx).youngs_modulus=2.4; db(idx).yield_strength=62; db(idx).uts=66;
    db(idx).elongation=110; db(idx).hardness=10; db(idx).thermal_conductivity=0.2;
    db(idx).thermal_expansion=65; db(idx).melting_point=267; db(idx).poissons_ratio=0.37;
    db(idx).cost=3.5; db(idx).specific_heat=1250;

    idx=idx+1; db(idx).name='PET'; db(idx).category='Polymer'; db(idx).subcategory='Thermoplastic';
    db(idx).density=1380; db(idx).youngs_modulus=2.8; db(idx).yield_strength=55; db(idx).uts=80;
    db(idx).elongation=300; db(idx).hardness=15; db(idx).thermal_conductivity=0.15;
    db(idx).thermal_expansion=60; db(idx).melting_point=260; db(idx).poissons_ratio=0.44;
    db(idx).cost=1.5; db(idx).specific_heat=1200;

    idx=idx+1; db(idx).name='PTFE (Teflon)'; db(idx).category='Polymer'; db(idx).subcategory='Fluoropolymer';
    db(idx).density=2200; db(idx).youngs_modulus=0.5; db(idx).yield_strength=23; db(idx).uts=27;
    db(idx).elongation=350; db(idx).hardness=5; db(idx).thermal_conductivity=0.25;
    db(idx).thermal_expansion=135; db(idx).melting_point=327; db(idx).poissons_ratio=0.46;
    db(idx).cost=8.0; db(idx).specific_heat=1000;

    idx=idx+1; db(idx).name='Epoxy'; db(idx).category='Polymer'; db(idx).subcategory='Thermoset';
    db(idx).density=1200; db(idx).youngs_modulus=3.5; db(idx).yield_strength=60; db(idx).uts=85;
    db(idx).elongation=5; db(idx).hardness=15; db(idx).thermal_conductivity=0.2;
    db(idx).thermal_expansion=55; db(idx).melting_point=200; db(idx).poissons_ratio=0.35;
    db(idx).cost=5.0; db(idx).specific_heat=1100;

    idx=idx+1; db(idx).name='Natural Rubber'; db(idx).category='Polymer'; db(idx).subcategory='Elastomer';
    db(idx).density=920; db(idx).youngs_modulus=0.003; db(idx).yield_strength=20; db(idx).uts=25;
    db(idx).elongation=800; db(idx).hardness=3; db(idx).thermal_conductivity=0.13;
    db(idx).thermal_expansion=200; db(idx).melting_point=80; db(idx).poissons_ratio=0.49;
    db(idx).cost=1.5; db(idx).specific_heat=1880;

    % --- Composites ---
    idx=idx+1; db(idx).name='CFRP (Carbon/Epoxy)'; db(idx).category='Composite'; db(idx).subcategory='Fiber Reinforced';
    db(idx).density=1600; db(idx).youngs_modulus=181; db(idx).yield_strength=1500; db(idx).uts=1860;
    db(idx).elongation=1.7; db(idx).hardness=70; db(idx).thermal_conductivity=7;
    db(idx).thermal_expansion=0.2; db(idx).melting_point=300; db(idx).poissons_ratio=0.27;
    db(idx).cost=40.0; db(idx).specific_heat=900;

    idx=idx+1; db(idx).name='GFRP (Glass/Epoxy)'; db(idx).category='Composite'; db(idx).subcategory='Fiber Reinforced';
    db(idx).density=2000; db(idx).youngs_modulus=45; db(idx).yield_strength=500; db(idx).uts=700;
    db(idx).elongation=3; db(idx).hardness=30; db(idx).thermal_conductivity=0.8;
    db(idx).thermal_expansion=10; db(idx).melting_point=250; db(idx).poissons_ratio=0.28;
    db(idx).cost=8.0; db(idx).specific_heat=1000;

    idx=idx+1; db(idx).name='Kevlar/Epoxy'; db(idx).category='Composite'; db(idx).subcategory='Fiber Reinforced';
    db(idx).density=1380; db(idx).youngs_modulus=76; db(idx).yield_strength=1240; db(idx).uts=1400;
    db(idx).elongation=2.5; db(idx).hardness=40; db(idx).thermal_conductivity=0.4;
    db(idx).thermal_expansion=4; db(idx).melting_point=300; db(idx).poissons_ratio=0.34;
    db(idx).cost=35.0; db(idx).specific_heat=1420;

    idx=idx+1; db(idx).name='WC-Co (Cemented Carbide)'; db(idx).category='Composite'; db(idx).subcategory='Metal Matrix';
    db(idx).density=14900; db(idx).youngs_modulus=620; db(idx).yield_strength=4000; db(idx).uts=1500;
    db(idx).elongation=0; db(idx).hardness=1600; db(idx).thermal_conductivity=84;
    db(idx).thermal_expansion=5.2; db(idx).melting_point=2870; db(idx).poissons_ratio=0.22;
    db(idx).cost=50.0; db(idx).specific_heat=240;

    idx=idx+1; db(idx).name='Concrete'; db(idx).category='Composite'; db(idx).subcategory='Particulate';
    db(idx).density=2400; db(idx).youngs_modulus=30; db(idx).yield_strength=40; db(idx).uts=4;
    db(idx).elongation=0; db(idx).hardness=200; db(idx).thermal_conductivity=1.7;
    db(idx).thermal_expansion=12; db(idx).melting_point=1500; db(idx).poissons_ratio=0.2;
    db(idx).cost=0.05; db(idx).specific_heat=880;

    idx=idx+1; db(idx).name='Plywood'; db(idx).category='Composite'; db(idx).subcategory='Natural';
    db(idx).density=600; db(idx).youngs_modulus=12; db(idx).yield_strength=40; db(idx).uts=50;
    db(idx).elongation=2; db(idx).hardness=20; db(idx).thermal_conductivity=0.13;
    db(idx).thermal_expansion=5; db(idx).melting_point=250; db(idx).poissons_ratio=0.3;
    db(idx).cost=0.8; db(idx).specific_heat=1700;

    % --- Additional Metals ---
    idx=idx+1; db(idx).name='AISI 4340 Steel'; db(idx).category='Metal'; db(idx).subcategory='Alloy Steel';
    db(idx).density=7850; db(idx).youngs_modulus=205; db(idx).yield_strength=860; db(idx).uts=1080;
    db(idx).elongation=12; db(idx).hardness=321; db(idx).thermal_conductivity=44.5;
    db(idx).thermal_expansion=12.3; db(idx).melting_point=1427; db(idx).poissons_ratio=0.29;
    db(idx).cost=1.5; db(idx).specific_heat=475;

    idx=idx+1; db(idx).name='Maraging Steel 250'; db(idx).category='Metal'; db(idx).subcategory='Alloy Steel';
    db(idx).density=8000; db(idx).youngs_modulus=186; db(idx).yield_strength=1700; db(idx).uts=1800;
    db(idx).elongation=8; db(idx).hardness=500; db(idx).thermal_conductivity=25.5;
    db(idx).thermal_expansion=10.1; db(idx).melting_point=1413; db(idx).poissons_ratio=0.30;
    db(idx).cost=15.0; db(idx).specific_heat=450;

    idx=idx+1; db(idx).name='Tool Steel D2'; db(idx).category='Metal'; db(idx).subcategory='Tool Steel';
    db(idx).density=7700; db(idx).youngs_modulus=210; db(idx).yield_strength=1650; db(idx).uts=1850;
    db(idx).elongation=1; db(idx).hardness=620; db(idx).thermal_conductivity=20;
    db(idx).thermal_expansion=10.4; db(idx).melting_point=1421; db(idx).poissons_ratio=0.28;
    db(idx).cost=5.0; db(idx).specific_heat=460;

    idx=idx+1; db(idx).name='Cast Iron (Gray)'; db(idx).category='Metal'; db(idx).subcategory='Cast Iron';
    db(idx).density=7150; db(idx).youngs_modulus=100; db(idx).yield_strength=230; db(idx).uts=290;
    db(idx).elongation=0.5; db(idx).hardness=200; db(idx).thermal_conductivity=46;
    db(idx).thermal_expansion=10.5; db(idx).melting_point=1200; db(idx).poissons_ratio=0.26;
    db(idx).cost=0.6; db(idx).specific_heat=490;

    idx=idx+1; db(idx).name='Al 5052-H32'; db(idx).category='Metal'; db(idx).subcategory='Aluminum Alloy';
    db(idx).density=2680; db(idx).youngs_modulus=70.3; db(idx).yield_strength=193; db(idx).uts=228;
    db(idx).elongation=12; db(idx).hardness=60; db(idx).thermal_conductivity=138;
    db(idx).thermal_expansion=23.8; db(idx).melting_point=649; db(idx).poissons_ratio=0.33;
    db(idx).cost=2.2; db(idx).specific_heat=880;

    idx=idx+1; db(idx).name='Bronze C932'; db(idx).category='Metal'; db(idx).subcategory='Copper Alloy';
    db(idx).density=8800; db(idx).youngs_modulus=103; db(idx).yield_strength=152; db(idx).uts=241;
    db(idx).elongation=8; db(idx).hardness=65; db(idx).thermal_conductivity=59;
    db(idx).thermal_expansion=18.0; db(idx).melting_point=1000; db(idx).poissons_ratio=0.34;
    db(idx).cost=5.0; db(idx).specific_heat=376;

    idx=idx+1; db(idx).name='Zinc Alloy (Zamak 3)'; db(idx).category='Metal'; db(idx).subcategory='Zinc Alloy';
    db(idx).density=6600; db(idx).youngs_modulus=85; db(idx).yield_strength=221; db(idx).uts=283;
    db(idx).elongation=10; db(idx).hardness=82; db(idx).thermal_conductivity=113;
    db(idx).thermal_expansion=27.4; db(idx).melting_point=387; db(idx).poissons_ratio=0.33;
    db(idx).cost=2.0; db(idx).specific_heat=419;

    idx=idx+1; db(idx).name='Tungsten'; db(idx).category='Metal'; db(idx).subcategory='Refractory Metal';
    db(idx).density=19300; db(idx).youngs_modulus=411; db(idx).yield_strength=750; db(idx).uts=980;
    db(idx).elongation=2; db(idx).hardness=350; db(idx).thermal_conductivity=173;
    db(idx).thermal_expansion=4.5; db(idx).melting_point=3422; db(idx).poissons_ratio=0.28;
    db(idx).cost=35.0; db(idx).specific_heat=132;

    idx=idx+1; db(idx).name='Molybdenum'; db(idx).category='Metal'; db(idx).subcategory='Refractory Metal';
    db(idx).density=10220; db(idx).youngs_modulus=329; db(idx).yield_strength=550; db(idx).uts=690;
    db(idx).elongation=25; db(idx).hardness=230; db(idx).thermal_conductivity=138;
    db(idx).thermal_expansion=4.8; db(idx).melting_point=2623; db(idx).poissons_ratio=0.31;
    db(idx).cost=40.0; db(idx).specific_heat=251;

    idx=idx+1; db(idx).name='Beryllium Copper C17200'; db(idx).category='Metal'; db(idx).subcategory='Copper Alloy';
    db(idx).density=8250; db(idx).youngs_modulus=131; db(idx).yield_strength=1035; db(idx).uts=1310;
    db(idx).elongation=3; db(idx).hardness=370; db(idx).thermal_conductivity=107;
    db(idx).thermal_expansion=17.1; db(idx).melting_point=870; db(idx).poissons_ratio=0.30;
    db(idx).cost=20.0; db(idx).specific_heat=420;

    idx=idx+1; db(idx).name='Hastelloy C-276'; db(idx).category='Metal'; db(idx).subcategory='Nickel Superalloy';
    db(idx).density=8890; db(idx).youngs_modulus=205; db(idx).yield_strength=355; db(idx).uts=790;
    db(idx).elongation=60; db(idx).hardness=194; db(idx).thermal_conductivity=10.2;
    db(idx).thermal_expansion=11.2; db(idx).melting_point=1370; db(idx).poissons_ratio=0.31;
    db(idx).cost=35.0; db(idx).specific_heat=427;

    idx=idx+1; db(idx).name='Pure Nickel 200'; db(idx).category='Metal'; db(idx).subcategory='Nickel';
    db(idx).density=8890; db(idx).youngs_modulus=207; db(idx).yield_strength=148; db(idx).uts=462;
    db(idx).elongation=47; db(idx).hardness=109; db(idx).thermal_conductivity=70;
    db(idx).thermal_expansion=13.3; db(idx).melting_point=1455; db(idx).poissons_ratio=0.31;
    db(idx).cost=15.0; db(idx).specific_heat=456;

    idx=idx+1; db(idx).name='Lead (Pure)'; db(idx).category='Metal'; db(idx).subcategory='Heavy Metal';
    db(idx).density=11340; db(idx).youngs_modulus=16; db(idx).yield_strength=11; db(idx).uts=17;
    db(idx).elongation=50; db(idx).hardness=5; db(idx).thermal_conductivity=35.3;
    db(idx).thermal_expansion=28.9; db(idx).melting_point=327; db(idx).poissons_ratio=0.44;
    db(idx).cost=2.0; db(idx).specific_heat=129;

    idx=idx+1; db(idx).name='Tin (Pure)'; db(idx).category='Metal'; db(idx).subcategory='Soft Metal';
    db(idx).density=7310; db(idx).youngs_modulus=50; db(idx).yield_strength=14; db(idx).uts=22;
    db(idx).elongation=40; db(idx).hardness=6; db(idx).thermal_conductivity=66.8;
    db(idx).thermal_expansion=22.0; db(idx).melting_point=232; db(idx).poissons_ratio=0.36;
    db(idx).cost=18.0; db(idx).specific_heat=228;

    % --- Additional Ceramics ---
    idx=idx+1; db(idx).name='Tungsten Carbide (WC)'; db(idx).category='Ceramic'; db(idx).subcategory='Carbide Ceramic';
    db(idx).density=15630; db(idx).youngs_modulus=700; db(idx).yield_strength=5000; db(idx).uts=350;
    db(idx).elongation=0; db(idx).hardness=2200; db(idx).thermal_conductivity=110;
    db(idx).thermal_expansion=5.2; db(idx).melting_point=2870; db(idx).poissons_ratio=0.31;
    db(idx).cost=40.0; db(idx).specific_heat=203;

    idx=idx+1; db(idx).name='Boron Nitride (hBN)'; db(idx).category='Ceramic'; db(idx).subcategory='Nitride Ceramic';
    db(idx).density=2100; db(idx).youngs_modulus=36; db(idx).yield_strength=400; db(idx).uts=80;
    db(idx).elongation=0; db(idx).hardness=200; db(idx).thermal_conductivity=30;
    db(idx).thermal_expansion=1.0; db(idx).melting_point=2973; db(idx).poissons_ratio=0.25;
    db(idx).cost=50.0; db(idx).specific_heat=800;

    idx=idx+1; db(idx).name='Soda-Lime Glass'; db(idx).category='Ceramic'; db(idx).subcategory='Glass';
    db(idx).density=2500; db(idx).youngs_modulus=72; db(idx).yield_strength=200; db(idx).uts=50;
    db(idx).elongation=0; db(idx).hardness=500; db(idx).thermal_conductivity=1.0;
    db(idx).thermal_expansion=9.0; db(idx).melting_point=730; db(idx).poissons_ratio=0.22;
    db(idx).cost=0.5; db(idx).specific_heat=840;

    idx=idx+1; db(idx).name='Porcelain'; db(idx).category='Ceramic'; db(idx).subcategory='Traditional Ceramic';
    db(idx).density=2400; db(idx).youngs_modulus=70; db(idx).yield_strength=500; db(idx).uts=55;
    db(idx).elongation=0; db(idx).hardness=700; db(idx).thermal_conductivity=1.5;
    db(idx).thermal_expansion=6.0; db(idx).melting_point=1400; db(idx).poissons_ratio=0.25;
    db(idx).cost=3.0; db(idx).specific_heat=1085;

    % --- Additional Polymers ---
    idx=idx+1; db(idx).name='ABS'; db(idx).category='Polymer'; db(idx).subcategory='Thermoplastic';
    db(idx).density=1050; db(idx).youngs_modulus=2.3; db(idx).yield_strength=43; db(idx).uts=48;
    db(idx).elongation=30; db(idx).hardness=10; db(idx).thermal_conductivity=0.17;
    db(idx).thermal_expansion=90; db(idx).melting_point=230; db(idx).poissons_ratio=0.35;
    db(idx).cost=2.0; db(idx).specific_heat=1400;

    idx=idx+1; db(idx).name='PEEK'; db(idx).category='Polymer'; db(idx).subcategory='High Performance';
    db(idx).density=1310; db(idx).youngs_modulus=4.1; db(idx).yield_strength=100; db(idx).uts=110;
    db(idx).elongation=50; db(idx).hardness=25; db(idx).thermal_conductivity=0.25;
    db(idx).thermal_expansion=47; db(idx).melting_point=343; db(idx).poissons_ratio=0.40;
    db(idx).cost=80.0; db(idx).specific_heat=1340;

    idx=idx+1; db(idx).name='PVC (Rigid)'; db(idx).category='Polymer'; db(idx).subcategory='Thermoplastic';
    db(idx).density=1400; db(idx).youngs_modulus=3.3; db(idx).yield_strength=52; db(idx).uts=58;
    db(idx).elongation=40; db(idx).hardness=12; db(idx).thermal_conductivity=0.16;
    db(idx).thermal_expansion=70; db(idx).melting_point=212; db(idx).poissons_ratio=0.38;
    db(idx).cost=1.0; db(idx).specific_heat=1050;

    idx=idx+1; db(idx).name='Polyimide (Kapton)'; db(idx).category='Polymer'; db(idx).subcategory='High Performance';
    db(idx).density=1420; db(idx).youngs_modulus=3.0; db(idx).yield_strength=72; db(idx).uts=231;
    db(idx).elongation=72; db(idx).hardness=18; db(idx).thermal_conductivity=0.12;
    db(idx).thermal_expansion=20; db(idx).melting_point=410; db(idx).poissons_ratio=0.34;
    db(idx).cost=50.0; db(idx).specific_heat=1090;

    idx=idx+1; db(idx).name='UHMWPE'; db(idx).category='Polymer'; db(idx).subcategory='Thermoplastic';
    db(idx).density=940; db(idx).youngs_modulus=0.7; db(idx).yield_strength=22; db(idx).uts=42;
    db(idx).elongation=350; db(idx).hardness=7; db(idx).thermal_conductivity=0.42;
    db(idx).thermal_expansion=150; db(idx).melting_point=130; db(idx).poissons_ratio=0.46;
    db(idx).cost=4.0; db(idx).specific_heat=1850;

    idx=idx+1; db(idx).name='Silicone Rubber'; db(idx).category='Polymer'; db(idx).subcategory='Elastomer';
    db(idx).density=1100; db(idx).youngs_modulus=0.005; db(idx).yield_strength=8; db(idx).uts=10;
    db(idx).elongation=600; db(idx).hardness=2; db(idx).thermal_conductivity=0.20;
    db(idx).thermal_expansion=250; db(idx).melting_point=300; db(idx).poissons_ratio=0.49;
    db(idx).cost=6.0; db(idx).specific_heat=1460;

    % --- Additional Composites ---
    idx=idx+1; db(idx).name='Al-SiC MMC (20%)'; db(idx).category='Composite'; db(idx).subcategory='Metal Matrix';
    db(idx).density=2850; db(idx).youngs_modulus=100; db(idx).yield_strength=350; db(idx).uts=450;
    db(idx).elongation=4; db(idx).hardness=140; db(idx).thermal_conductivity=170;
    db(idx).thermal_expansion=14; db(idx).melting_point=620; db(idx).poissons_ratio=0.29;
    db(idx).cost=15.0; db(idx).specific_heat=800;

    idx=idx+1; db(idx).name='Basalt Fiber/Epoxy'; db(idx).category='Composite'; db(idx).subcategory='Fiber Reinforced';
    db(idx).density=1900; db(idx).youngs_modulus=60; db(idx).yield_strength=400; db(idx).uts=550;
    db(idx).elongation=2.5; db(idx).hardness=35; db(idx).thermal_conductivity=0.6;
    db(idx).thermal_expansion=8; db(idx).melting_point=280; db(idx).poissons_ratio=0.30;
    db(idx).cost=10.0; db(idx).specific_heat=900;

    % Property units:
    % density: kg/m^3
    % youngs_modulus: GPa
    % yield_strength: MPa
    % uts: MPa
    % elongation: %
    % hardness: HV (Vickers) or Shore as appropriate
    % thermal_conductivity: W/(m*K)
    % thermal_expansion: um/(m*K) i.e. 1e-6/K
    % melting_point: deg C
    % poissons_ratio: dimensionless
    % cost: $/kg (approximate)
    % specific_heat: J/(kg*K)
end
