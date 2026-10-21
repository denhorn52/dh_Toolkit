-- dh_HearingTest_data.lua

-- Modified 20261002

-----------------------------------
dh_HearingTest_data = {}
-----------------------------------

-- This needs to correspond with zones.
-- Will populate menubox, and is used for lookup.

dh_HearingTest_data.frequencies = {
    '33',      -- th = 55,    C1 32.703    
    '49',      -- th = 43,    G1 49    
    '82',      -- th = 30,    E2 82.41
    '131',     -- th = 20,    C3 130.81 
    '196',     -- th = 13,    G3 196     F#3 185
    '262',     -- th = 10,    C4 261.63  E4 329.628
    '392',     -- th = 6.5,   G4 392     F#4 369.99
    '523',     -- th = 3.5,   C5 523.25  
    '659',     -- th = 2.5,   E5 659.25 
    '784',     -- th = 2,     G5 783.99
    '932',     -- th = 2,     A#5 932.33 
    '1047',    -- th = 2,     C6 1046.5 
    '1319',    -- th = 3,     E6 1318.51
    '1568',    -- th = 3,     G6 1567.98
    '2093',    -- th = -2.5,  C7 2093 
    '2637',    -- th = -5.5,  E7 2637.02
    '3136',    -- th = -6.5,  G7 3135.96
    '3729',    -- th = -5.8,  A#7 3729.31 
    '4186',    -- th = -4,    C8 4186
    '4699',    -- th = -4,    D8 4698.64
    '5274',    -- th = 0,     E8 5274
    '6272',    -- th = 6,     G8 6271.93 
    '7459',    -- th = 10,    A#8 7458.62 
    '8372',    -- th = 12,    C9 8372.02
    '10548',   -- th = 14,    E9 10548.08
    --12544,   -- th = 13,    G9 12543.85
    --16744,   -- th = 12,    C10 16744.04
    
}


dh_HearingTest_data.zones = {

['33'] = {
  frequency = 33,  -- 32.70
  note = "C",      -- C1,
  note_idx = 3,
  octave = -4,
  --threshhold = 59,  --47, 
  -- (equal loud 109.00 at 80, 98.2 at 60, 93.6 at 50 phon, 88 at 40, 98.2)
  --max_gain = 9,
  locked = false, 
  bypass = false,
  
  gain_l = 0,
  gain_r = 0,
  gain_c = 0,
  
  test_ref_pan = 0,    
  test_gain_adj = 0,
  test_pan = 0,
  
  gain2_l = 0,
  gain2_r = 0,
  
  lr_gain = 0,
  lr_cents = 0,
},

['49'] = {
  frequency = 49,  -- 49,
  note = "G",      -- G1,
  note_idx = 10,
  octave = -4,
  --threshhold = 44, 
  -- (equal loud 101.36 at 80, 90.4 at 60, 84 at 50 phon, 78.3 at 40)
  --max_gain = 9,
  locked = false, 
  bypass = false,
  
  gain_l = 0,
  gain_r = 0,
  gain_c = 0,
  
  test_ref_pan = 0,    
  test_gain_adj = 0,
  test_pan = 0,
  
  gain2_l = 0,
  gain2_r = 0,
  
  lr_gain = 0,
  lr_cents = 0,
},  

['82'] = {
  frequency = 82,  -- 82.41,
  note = "E",      -- E2,
  note_idx = 7,  
  octave = -3,
  --threshhold = 31, 
  -- (equal loud 94.90 at 80, 81.71 at 60, 75 at 50 phon, 68.1)
  --max_gain = 9,
  locked = false, 
  bypass = false,
  
  gain_l = 0,
  gain_r = 0,
  gain_c = 0,
  
  test_ref_pan = 0,    
  test_gain_adj = 0,
  test_pan = 0,
  
  gain2_l = 0,
  gain2_r = 0,
  
  lr_gain = 0,
  lr_cents = 0,
},  

['131'] = {
  frequency = 131,  -- 130.81,
  note = "C",       -- C3,
  note_idx = 3,  
  octave = -2,
  --threshhold = 22,  
  -- (equal loud 90.43 at 80, 75.03 at 60, 67.6 at 50 phon, 60 at 40)
  --max_gain = 9,
  locked = false, 
  bypass = false,
  
  gain_l = 0,
  gain_r = 0,
  gain_c = 0,
  
  test_ref_pan = 0,    
  test_gain_adj = 0,
  test_pan = 0,
  
  gain2_l = 0,
  gain2_r = 0,
  
  lr_gain = 0,
  lr_cents = 0,
},  

['196'] = {
  frequency = 196,  -- 196,
  note = "G",       -- G3,
  note_idx = 10,  
  octave = -2,
  --threshhold = 14.6,  
  -- (equal loud 87.00 at 80, 70.1 at 60, 62 at 50 phon, 53.7 at 40)
  --max_gain = 9,
  locked = false, 
  bypass = false,
  
  gain_l = 0,
  gain_r = 0,
  gain_c = 0,
  
  test_ref_pan = 0,    
  test_gain_adj = 0,
  test_pan = 0,
  
  gain2_l = 0,
  gain2_r = 0,
  
  lr_gain = 0,
  lr_cents = 0,
},  

['262'] = {
  frequency = 262,  -- 262.31,
  note = "C",       -- C4, middle C
  note_idx = 3, 
  octave = -1,
  --threshhold = 10.7,  
  -- (equal loud 80.23 at 80, 67.3 at 60, 58.8 at 50 phon, 49.9 at 40)
  --max_gain = 9,
  locked = false, 
  bypass = false,
  
  gain_l = 0,
  gain_r = 0,
  gain_c = 0,
  
  test_ref_pan = 0,    
  test_gain_adj = 0,
  test_pan = 0,
  
  gain2_l = 0,
  gain2_r = 0,
  
  lr_gain = 0,
  lr_cents = 0,
},  

['392'] = {
  frequency = 392,  -- 392,
  note = "G",       -- G4,
  note_idx = 10,  
  octave = -1,
  --threshhold = 6.5, 
  -- (equal loud 81.79 at 80, 63.63 at 60, 54.5 at 50, 45.2 at 40) 
  --max_gain = 9,
  locked = false, 
  bypass = false,
  
  gain_l = 0,
  gain_r = 0,
  gain_c = 0,
  
  test_ref_pan = 0,    
  test_gain_adj = 0,
  test_pan = 0,
  
  gain2_l = 0,
  gain2_r = 0,
  
  lr_gain = 0,
  lr_cents = 0,
},  

['523'] = {
  frequency = 523,  -- 523.25,
  note = "C",       -- C5,
  note_idx = 3,  
  octave = 0,
  --threshhold = 4, 
  -- (equal loud 80.61 at 80, 61.83 at 60, 52.3 at 50 phon, 42.7 at 40)
  --max_gain = 9,
  locked = false, 
  bypass = false,
  
  gain_l = 0,
  gain_r = 0,
  gain_c = 0,
  
  test_ref_pan = 0,    
  test_gain_adj = 0,
  test_pan = 0,
  
  gain2_l = 0,
  gain2_r = 0,
  
  lr_gain = 0,
  lr_cents = 0,
},  

['659'] = {
  frequency = 659,  -- 659.25,
  note = "E",       -- E5,
  note_idx = 7,
  octave = 0,
  --threshhold = 2.9, 
  -- (equal loud 80.08 at 80, 60.65 at 60, 51 at 50 phon, 41.1 at 40)
  --max_gain = 9,
  locked = false, 
  bypass = false,
  
  gain_l = 0,
  gain_r = 0,
  gain_c = 0,
  
  test_ref_pan = 0,    
  test_gain_adj = 0,
  test_pan = 0,
  
  gain2_l = 0,
  gain2_r = 0,
  
  lr_gain = 0,
  lr_cents = 0,
},  

['784'] = {
  frequency = 784,  -- 783.99,
  note = "G",       -- G5,
  note_idx = 10,
  octave = 0,
  --threshhold = 2.3,   
  -- (equal loud 80.06 at 80, 59.98 at 60, 50.2 at 50 phon, 40.2 at 40)
  --max_gain = 9,
  locked = false, 
  bypass = false,
  
  gain_l = 0,
  gain_r = 0,
  gain_c = 0,
  
  test_ref_pan = 0,    
  test_gain_adj = 0,
  test_pan = 0,
  
  gain2_l = 0,
  gain2_r = 0,
  
  lr_gain = 0,
  lr_cents = 0,
},  

['932'] = {
  frequency = 932,  -- 932.33,
  note = "A#",       -- A#5,
  note_idx = 1,
  octave = 1,
  --threshhold = 2.3,   
  -- (equal loud 80.09 at 80, 59.98 at 60, 50 at 50 phon, 40 at 40)
  --max_gain = 9,
  locked = false, 
  bypass = false,
  
  gain_l = 0,
  gain_r = 0,
  gain_c = 0,
  
  test_ref_pan = 0,    
  test_gain_adj = 0,
  test_pan = 0,
  
  gain2_l = 0,
  gain2_r = 0,
  
  lr_gain = 0,
  lr_cents = 0,
}, 

-- Datum frequency, has additional items.
['1047'] = {
  frequency = 1047,  -- 1046.5,
  note = "C",        -- C6,
  note_idx = 3, 
  octave = 1,
  --threshhold = 2.6,  -- dB threshhold of normal hearinh.
  -- (equal loud 80.31 at 80, 60.41 at 60, 50.4 at 50 phon,40.3 at 40)
  --max_gain = 9,
  locked = true, 
  bypass = false,
  
  -- Default presets for test datum tone.
  phon_curve = 80,
  datum_pan = 0, -- used for Test2
  datum_gain = -18,
  tg_gain = -12,
  
  -- Used to store results of Test 1.
  -- Values are dB adjustments to eq loud ref.
  gain_l = 0,
  gain_r = 0,
  gain_c = 0,
  
  -- Used to store results of Test2.
  -- test_gain_adj and test_pan used to initialize test.
  -- l/r values are calculated dB adjustments to eq loud ref.

  test_ref_pan = 0,    --!!! May not be using this    
  test_gain_adj = 0,
  test_pan = 0,
  gain2_l = 0,
  gain2_r = 0,
  
  -- Used to store results of LR Test.
  lr_gain = 0,
  lr_cents = 0,
},  

['1319'] = {
  frequency = 1319,  -- 1318.51,
  note = "E",        -- E6,
  note_idx = 7, 
  octave = 1,
  --threshhold = 3,    
  -- (equal loud 82.23 at 80, 62.36 at 60, 52.2 at 50 phon, 42 at 40)
  --max_gain = 9,
  locked = false, 
  bypass = false,

  gain_l = 0,
  gain_r = 0,
  gain_c = 0,
  
  test_ref_pan = 0,    
  test_gain_adj = 0,
  test_pan = 0,
  
  gain2_l = 0,
  gain2_r = 0,

  lr_gain = 0,
  lr_cents = 0,
},  

['1568'] = {
  frequency = 1568,  -- 1567.98,
  note = "G",        -- G6,
  note_idx = 10, 
  octave = 1,
  --threshhold = 2,    
  -- (equal loud 83.45 at 80, 63.1 at 60, 52.8 at 50 phon, 42.5 at 40)
  --max_gain = 9,
  locked = false, 
  bypass = false,
  
  gain_l = 0,
  gain_r = 0,
  gain_c = 0,
  
  test_ref_pan = 0,    
  test_gain_adj = 0,
  test_pan = 0,
  
  gain2_l = 0,
  gain2_r = 0,
  
  lr_gain = 0,
  lr_cents = 0,
},  

['2093'] = {
  frequency = 2093,  -- 2093,
  note = "C",        -- C7,
  note_idx = 3,  
  octave = 2,
  --threshhold = -2, 
  -- (equal loud 80.37 at 80, 59.46 at 60, 49.2 at 50 phon, 39.7 at 40)
  --max_gain = 9,
  locked = false, 
  bypass = false,
  
  gain_l = 0,
  gain_r = 0,
  gain_c = 0,
  
  test_ref_pan = 0,    
  test_gain_adj = 0,
  test_pan = 0,
  
  gain2_l = 0,
  gain2_r = 0,
  
  lr_gain = 0,
  lr_cents = 0,
},  

['2637'] = {
  frequency = 2637,  -- 2637.02,
  note = "E",        -- E7,
  note_idx = 7, 
  octave = 2,
  --threshhold = -4.7, 
  -- (equal loud 77.71 at 80, 57.07 at 60, 46.7 at 50 phon, 36.3 at 40)
  --max_gain = 9,
  locked = false, 
  bypass = false,
  
  gain_l = 0,
  gain_r = 0,
  gain_c = 0,
  
  test_ref_pan = 0,    
  test_gain_adj = 0,
  test_pan = 0,
  
  gain2_l = 0,
  gain2_r = 0,
  
  lr_gain = 0,
  lr_cents = 0,
},  

['3136'] = {
  frequency = 3136,  -- 3135.96,
  note = "G",        -- G7,
  note_idx = 10,
  octave = 2,
  --threshhold = -5.8, 
  -- (equal loud 77.09 at 80, 56.44 at 60, 46.1 at 50 phon, 35.6 at 40)
  --max_gain = 9,
  locked = false, 
  bypass = false,
  
  gain_l = 0,
  gain_r = 0,
  gain_c = 0,
  
  test_ref_pan = 0,    
  test_gain_adj = 0,
  test_pan = 0,
  
  gain2_l = 0,
  gain2_r = 0,
  
  lr_gain = 0,
  lr_cents = 0,
},

['3729'] = {
  frequency = 3729,  -- 3729.31,
  note = "A#",       -- A#7,
  note_idx = 1,
  octave = 3,
  --threshhold = -5.8,   
  -- (equal loud 77.91 at 80, 57.23 at 60, 46.8 at 50 phon, 36.31 at 40)  
  --max_gain = 9,
  locked = false,
  bypass = false,
  
  gain_l = 0,
  gain_r = 0,
  gain_c = 0,
  
  test_ref_pan = 0,    
  test_gain_adj = 0,
  test_pan = 0,
  
  gain2_l = 0,
  gain2_r = 0,
  
  lr_gain = 0,
  lr_cents = 0,
},   

['4186'] = {
  frequency = 4186,  -- 4186,
  note = "C",        -- C8,
  note_idx = 3,
  octave = 3,
  --threshhold = -4.6,   
  -- (equal loud 78.93 at 80, 58.22 at 60, 47.7 at 50 phon, 37.3 at 40)
  --max_gain = 9,
  locked = false,
  bypass = false,
  
  gain_l = 0,
  gain_r = 0,
  gain_c = 0,
  
  test_ref_pan = 0,    
  test_gain_adj = 0,
  test_pan = 0,
  
  gain2_l = 0,
  gain2_r = 0,
  
  lr_gain = 0,
  lr_cents = 0,
},

['4699'] = {
  frequency = 4699,  -- 4698.64,
  note = "D",        -- D8,
  note_idx = 5,
  octave = 3,
  --threshhold = -2.7,   
  -- (equal loud 79.92 at 80, 59.89 at 60, 49.48 at 50 phon, 39 at 40)  
  --max_gain = 9,
  locked = false,
  bypass = false,
  
  gain_l = 0,
  gain_r = 0,
  gain_c = 0,
  
  test_ref_pan = 0,    
  test_gain_adj = 0,
  test_pan = 0,
  
  gain2_l = 0,
  gain2_r = 0,
  
  lr_gain = 0,
  lr_cents = 0,
},  

['5274'] = {
  frequency = 5274,  -- 5274,
  note = "E",        -- E8,
  note_idx = 7,
  octave = 3,
  --threshhold = 0,    
  -- (equal loud 82.71 at 80, 62.04 at 60, 51.7 at 50 phon, 40.7)
  --max_gain = 9,
  locked = false, 
  bypass = false,
  
  gain_l = 0,
  gain_r = 0,
  gain_c = 0,
  
  test_ref_pan = 0,    
  test_gain_adj = 0,
  test_pan = 0,
  
  gain2_l = 0,
  gain2_r = 0,
  
  lr_gain = 0,
  lr_cents = 0,
},  

['6272'] = {
  frequency = 6272,  -- 6271.93,
  note = "G",        -- G8,
  note_idx = 10,
  octave = 3,
  --threshhold = 5.9,    
  -- (equal loud 86.70 at 80, 66.24 at 60, 56 at 50 phon, 45.8 at 40)
  --max_gain = 9,
  locked = false, 
  bypass = false,
  
  gain_l = 0,
  gain_r = 0,
  gain_c = 0,
  
  test_ref_pan = 0,    
  test_gain_adj = 0,
  test_pan = 0,
  
  gain2_l = 0,
  gain2_r = 0,
  
  lr_gain = 0,
  lr_cents = 0,
},  

['7459'] = {
  frequency = 7459,  -- 7458.62,
  note = "A#",       -- A#8,
  note_idx = 1,
  octave = 4,
  --threshhold = 10.5,   
  -- (equal loud 89.95 at 80, 69.97 at 60, 59 at 50 phon, 49.9 at 40)
  --max_gain = 9,
  locked = false,
  bypass = false,
  
  gain_l = 0,
  gain_r = 0,
  gain_c = 0,
  
  test_ref_pan = 0,    
  test_gain_adj = 0,
  test_pan = 0,
  
  gain2_l = 0,
  gain2_r = 0,
  
  lr_gain = 0,
  lr_cents = 0,
},  

['8372'] = {
  frequency = 8372,  -- 8372.02,
  note = "C",        -- C9,
  note_idx = 3,
  octave = 4,
  --threshhold = 12.8,   
  -- (equal loud 91.47 at 80, 71.94 at 60, 62.1 at 50 phon, 52.2 at 40)
  --max_gain = 9,
  locked = false, 
  bypass = false,
  
  gain_l = 0,
  gain_r = 0,
  gain_c = 0,
  
  test_ref_pan = 0,    
  test_gain_adj = 0,
  test_pan = 0,
  
  gain2_l = 0,
  gain2_r = 0,
  
  lr_gain = 0,
  lr_cents = 0,
},  
--zzz
['10548'] = {
  frequency = 10549,  -- 10548.08,
  note = "E",         -- E9,
  note_idx = 7,
  octave = 4,
  --threshhold = 14,    
  -- (equal loud 90.36 at 80, 72.16 at 60, 63.2 at 50 phon, 53.7 at 40)
  --max_gain = 9,
  locked = false, 
  bypass = false,
  
  gain_l = 0,
  gain_r = 0,
  gain_c = 0,
  
  test_ref_pan = 0,    
  test_gain_adj = 0,
  test_pan = 0,
  
  gain2_l = 0,
  gain2_r = 0,
  
  lr_gain = 0,
  lr_cents = 0,
},  

--[[
['12544'] = {
  frequency = 12544,  -- 12543.85,
  note = "G",         -- G9,
  note_idx = 10,
  octave = 4,
  --threshhold = 13,    
  -- (equal loud 85.40 at 80, 68.6 at 60, 60 at 50 phon, 51.4 at 40)
  --max_gain = 9,
  enabled = false, 
  bypass = false,
  
  gain_l = 0,
  gain_r = 0,
  gain_c = 0,
  
  test_ref_pan = 0,    
  test_gain_adj = 0,
  test_pan = 0,
  
  gain2_l = 0,
  gain2_r = 0,
  
  lr_gain = 0,
  lr_cents = 0,
}, 
--]] 
 
--[[ Cannot test this one if I wanted to.
['16744'] = {
  frequency = 16744,  --16743.85,
  note = "C",         -- C10,
  note_idx = 3,
  octave = 5,         -- octave 5 doesn't exist
  --threshhold = 12,    
  -- (equal loud 60? at 60, 50? at 50 phon, 40? at 40
  --max_gain = 9,
  enabled = false, 
  bypass = false,
  
  gain_l = 0,
  gain_r = 0,
  gain_c = 0,
  
  test_ref_pan = 0,    
  test_gain_adj = 0,
  test_pan = 0,
  
  gain2_l = 0,
  gain2_r = 0,
  
  lr_gain = 0,
  lr_cents = 0,
}, 
--]] 


}  -- <end zones> 


-- These values are approx. extrapolations.
-- Default dh_HearingTest configuration allows for +30dB 
-- gain adjustment including equal loudness offset.
--zzz
dh_HearingTest_data.phon_80 = {
  96.00,  -- 33hz: Should be 109.00, but limit it to a max of 96 to not clip and leave some headroom.
  96.00,  -- 49hz: Should be 101.36, but limit it to a max of 96 to not clip and leave some headroom.    
  94.90,  -- 82   
  90.43,  -- 131    
  86.00,  -- 196    
  80.23,  -- 262  
  81.79,  -- 392
  80.61,  -- 523
  80.08,  -- 659
  80.06,  -- 784
  80.09,  -- 932
  80.31,  -- 1047 datum
  82.23,  -- 1319
  83.45,  -- 1568
  80.37,  -- 2093
  77.71,  -- 2637
  77.09,  -- 3136
  77.91,  -- 3729
  78.93,  -- 4186
  79.92,  -- 4699
  82.71,  -- 5274
  86.70,  -- 6272
  89.95,  -- 7459
  91.47,  -- 8372  
  90.36,  -- 10548    
  --85.42,  -- 12544
}

dh_HearingTest_data.phon_60 = {
  84.00,  -- 33hz: Should be 98.20, but limit it to a amx of 84 to not clip and leave some headroom.
  84.00,  -- 49hz: Should be 90.40, but limit it to a amx of 84 to not clip and leave some headroom.    
  81.71,  -- 82   
  75.03,  -- 131    
  70.10,  -- 196    
  67.30,  -- 262  
  63.63,  -- 392
  61.83,  -- 523
  60.65,  -- 659
  60.00,  -- 784
  59.98,  -- 932
  60.41,  -- 1047 datum
  62.36,  -- 1319
  63.11,  -- 1568
  59.46,  -- 2093
  57.07,  -- 2637
  56.44,  -- 3136
  57.23,  -- 3729
  58.22,  -- 4186
  59.89,  -- 4699
  62.04,  -- 5274
  66.24,  -- 6272
  69.97,  -- 7459
  71.94,  -- 8372  
  72.16,  -- 10548    
  --68.60,  -- 12544
}

dh_HearingTest_data.phon_50 = {
  75.0, -- 33hz: Should be 93.6, but limit it to a amx of 75 to not clip and leave some headroom.
  75.0, -- 49hz: Should be 84.0, but limit it to a amx of 75 to not clip and leave some headroom.
  75.0,  -- 82
  67.6,  -- 131
  62.0,  -- 196
  58.8,  -- 262
  54.5,  -- 392
  52.3,  -- 532
  51.0,  -- 659
  50.2,  -- 784
  50.0,  -- 932
  50.4,  -- 1047 datum
  52.2,  -- 1319
  52.8,  -- 1568
  49.2,  -- 2093
  46.7,  -- 2637
  46.1,  -- 3136
  46.8,  -- 3729
  47.7,  -- 4186
  49.5,  -- 4699
  51.7,  -- 5274
  56.0,  -- 6272
  59.0,  -- 7459
  62.1,  -- 8372
  63.2,  -- 10548
  --60.1,  -- 22544
}

dh_HearingTest_data.phon_40 = {
  68.1, -- 33hz: Should be 88.0, but limit it to a amx of 68.1 to not clip and leave some headroom.
  68.1, -- 49hz: Should be 78.3, but limit it to a amx of 68.1 to not clip and leave some headroom.
  68.1,  -- 82
  60.0,  -- 131
  53.7,  -- 196
  49.9,  -- 262
  45.2,  -- 392
  42.7,  -- 532
  41.1,  -- 659
  40.2,  -- 784
  40.0,  -- 932
  40.3,  -- 1047 datum
  42.0,  -- 1319  
  42.5,  -- 1568
  39.7,  -- 2093
  36.3,  -- 2637
  35.6,  -- 3136
  36.3,  -- 3729
  37.3,  -- 4186
  39.0,  -- 4699
  40.7,  -- 5274
  45.8,  -- 6272
  49.9,  -- 7459
  52.2,  -- 8372
  53.7,  -- 10548
  --51.49, -- 12544 
}


return dh_HearingTest_data