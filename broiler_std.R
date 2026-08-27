# =============================================================================
# BROILER PERFORMANCE STANDARDS
#
# Returns standard performance values for Ross308 or Cobb500 broilers.
# 
#
# All performance data were extracted on:
# Cobb data: Cobb500, Broiler Performance & Nutrition, Supplement  (2022)
# Ross308, Broiler: Performance objectives (2022)
# 
#
# INPUTS
# -----------------------------------------------------------------------------
# age:
#   Bird age in days.
#   Can be an integer (35) or decimal value (35.5).
#
# genetic:
#   "Ross308"
#   "Cobb500"
#
# sex:
#   "as_hatched"
#   "female"
#   "male"
#
# parameter:
#   "bw"                 = body weight (g/bird)
#   "daily_feed_intake"  = daily feed intake (g/bird/day)
#   "cum_feed_intake"    = cumulative feed intake (g/bird)
#   "fcr"                = cumulative feed conversion ratio
#
# Output
# -----------------------------------------------------------------------------
# A single numeric value corresponding to the requested standard.
#
# Fractional ages are estimated using linear interpolation.
#
# Examples
# -----------------------------------------------------------------------------
#
# # Ross308 as-hatched body weight at 35 days
# broiler_std(
#   age = 35,
#   genetic = "Ross308",
#   sex = "as_hatched",
#   parameter = "bw"
# )
#
# # Ross308 female cumulative feed intake at 35 days
# broiler_std(
#   age = 35,
#   genetic = "Ross308",
#   sex = "female",
#   parameter = "cum_feed_intake"
# )
#
# # Cobb500 male daily feed intake at 42 days
# broiler_std(
#   age = 42,
#   genetic = "Cobb500",
#   sex = "male",
#   parameter = "daily_feed_intake"
# )
#
# # Cobb500 female FCR at 28 days
# broiler_std(
#   age = 28,
#   genetic = "Cobb500",
#   sex = "female",
#   parameter = "fcr"
# )
#
# # Body weight at a fractional age (linear interpolation)
# broiler_std(
#   age = 35.5,
#   genetic = "Ross308",
#   sex = "as_hatched",
#   parameter = "bw"
# )
#
# # Compare Ross308 and Cobb500 body weight at 42 days
# broiler_std(
#   age = 42,
#   genetic = "Ross308",
#   sex = "as_hatched",
#   parameter = "bw"
# )
#
# broiler_std(
#   age = 42,
#   genetic = "Cobb500",
#   sex = "as_hatched",
#   parameter = "bw"
# )
#
# # Store result in an object
# bw_42 <- broiler_std(
#   age = 42,
#   genetic = "Ross308",
#   sex = "as_hatched",
#   parameter = "bw"
# )
#
# print(bw_42)
#
# # Generate a complete BW curve from day 0 to 56
# age <- 0:56
#
# bw_curve <- sapply(
#   age,
#   function(x)
#     broiler_std(
#       age = x,
#       genetic = "Ross308",
#       sex = "as_hatched",
#       parameter = "bw"
#     )
# )
#
# plot(age,
#      bw_curve,
#      type = "l",
#      lwd = 2,
#      xlab = "Age (days)",
#      ylab = "Body weight (g)")
#
# =============================================================================

broiler_std <- function(age,
                        genetic = "Ross308",
                        sex = "as_hatched",
                        parameter = "bw") {
  
  # ---------------------------------------------------------------------------
  # Validate the age argument
  # ---------------------------------------------------------------------------
  
  if (!is.numeric(age) || length(age) != 1L || is.na(age) ||
      !is.finite(age)) {
    stop("age must be one finite, non-missing numeric value.")
  }
  
  if (age < 0 || age > 56) {
    stop("age must be between 0 and 56 days.")
  }
  
  # ---------------------------------------------------------------------------
  # Validate the genetic argument
  # ---------------------------------------------------------------------------
  
  valid_genetics <- c("Ross308", "Cobb500")
  
  if (!genetic %in% valid_genetics) {
    stop(
      "genetic must be one of: ",
      paste(valid_genetics, collapse = ", "),
      "."
    )
  }
  
  # ---------------------------------------------------------------------------
  # Validate the sex argument
  # ---------------------------------------------------------------------------
  
  valid_sexes <- c("as_hatched", "female", "male")
  
  if (!sex %in% valid_sexes) {
    stop(
      "sex must be one of: ",
      paste(valid_sexes, collapse = ", "),
      "."
    )
  }
  
  # ---------------------------------------------------------------------------
  # Validate the parameter argument
  # ---------------------------------------------------------------------------
  
  valid_parameters <- c(
    "bw",
    "daily_feed_intake",
    "cum_feed_intake",
    "fcr"
  )
  
  if (!parameter %in% valid_parameters) {
    stop(
      "parameter must be one of: ",
      paste(valid_parameters, collapse = ", "),
      "."
    )
  }
  
  # ---------------------------------------------------------------------------
  # Internal interpolation function
  #
  # R vectors start at position 1, but broiler ages start at day 0.
  # Therefore:
  #   day 0 = vector position 1
  #   day 1 = vector position 2
  #   day 56 = vector position 57
  # ---------------------------------------------------------------------------
  
  calc_value <- function(age, data) {
    
    # Check that the vector contains one value for every day from 0 to 56
    if (length(data) != 57L) {
      stop(
        "Internal data error: the selected performance vector must ",
        "contain 57 values, corresponding to days 0 through 56."
      )
    }
    
    # Separate the integer and decimal portions of age
    age_int <- floor(age)
    age_decimal_part <- age - age_int
    
    # Convert the age in days to the corresponding R vector position
    lower_position <- age_int + 1L
    
    # If age is a whole number, return the reported table value directly.
    # This also prevents an attempt to access position 58 at day 56.
    if (age_decimal_part == 0) {
      return(data[lower_position])
    }
    
    # Position corresponding to the following day
    upper_position <- lower_position + 1L
    
    # Values at the lower and upper ages
    lower_value <- data[lower_position]
    upper_value <- data[upper_position]
    
    # If either table value is unavailable, interpolation is not possible
    if (is.na(lower_value) || is.na(upper_value)) {
      return(NA_real_)
    }
    
    # Estimate the result using linear interpolation
    value <- lower_value +
      (upper_value - lower_value) * age_decimal_part
    
    return(value)
  }
  
  # ===========================================================================
  # ROSS 308 PERFORMANCE STANDARDS
  # ===========================================================================
  
  if (genetic == "Ross308") {
    
    # -------------------------------------------------------------------------
    # Ross308 female
    # -------------------------------------------------------------------------
    
    if (sex == "female") {
      
      if (parameter == "bw") {
        
        data_selected <- c(
          44, 63, 81, 103, 126, 152, 182, 214, 249, 287,
          328, 373, 421, 471, 525, 581, 641, 703, 768, 836,
          906, 978, 1052, 1129, 1207, 1287, 1369, 1452, 1536, 1622,
          1708, 1795, 1883, 1972, 2061, 2150, 2240, 2329, 2419, 2508,
          2597, 2686, 2774, 2862, 2949, 3035, 3121, 3205, 3289, 3372,
          3454, 3535, 3614, 3693, 3770, 3847, 3922
        )
      }
      
      if (parameter == "daily_feed_intake") {
        
        data_selected <- c(
          NA_real_, NA_real_, 17, 21, 25, 28, 32, 35, 39, 43,
          47, 51, 55, 60, 64, 69, 74, 79, 84, 89,
          94, 99, 104, 110, 115, 120, 125, 130, 135, 140,
          144, 149, 153, 158, 162, 166, 170, 173, 177, 180,
          183, 186, 189, 192, 194, 196, 199, 201, 202, 204,
          205, 207, 208, 209, 210, 210, 211
        )
      }
      
      if (parameter == "cum_feed_intake") {
        
        data_selected <- c(
          0, 13, 31, 52, 76, 104, 136, 171, 210, 253,
          299, 350, 405, 465, 529, 598, 672, 751, 835, 924,
          1018, 1117, 1221, 1331, 1446, 1566, 1691, 1821, 1956, 2095,
          2240, 2389, 2542, 2700, 2862, 3028, 3197, 3371, 3547, 3728,
          3911, 4097, 4286, 4478, 4672, 4869, 5067, 5268, 5470, 5674,
          5879, 6086, 6294, 6503, 6712, 6923, 7133
        )
      }
      
      if (parameter == "fcr") {
        
        data_selected <- c(
          NA_real_, 0.211, 0.375, 0.503, 0.604, 0.684, 0.748,
          0.800, 0.843, 0.880, 0.911, 0.939, 0.964, 0.987,
          1.009, 1.029, 1.049, 1.068, 1.087, 1.105,
          1.124, 1.142, 1.161, 1.179, 1.198, 1.217,
          1.235, 1.254, 1.273, 1.292, 1.311, 1.331,
          1.350, 1.369, 1.389, 1.408, 1.428, 1.447,
          1.467, 1.486, 1.506, 1.526, 1.545, 1.565,
          1.585, 1.604, 1.624, 1.643, 1.663, 1.683,
          1.702, 1.722, 1.741, 1.761, 1.780, 1.800, 1.819
        )
      }
    }
    
    # -------------------------------------------------------------------------
    # Ross308 as-hatched
    # -------------------------------------------------------------------------
    
    if (sex == "as_hatched") {
      
      if (parameter == "bw") {
        
        data_selected <- c(
          44, 62, 81, 102, 125, 151, 181, 213, 249, 288,
          330, 376, 425, 477, 533, 592, 655, 720, 789, 860,
          935, 1012, 1092, 1174, 1258, 1345, 1434, 1524, 1616, 1710,
          1805, 1901, 1999, 2097, 2196, 2296, 2396, 2496, 2597, 2697,
          2798, 2898, 2998, 3097, 3197, 3295, 3393, 3490, 3586, 3681,
          3776, 3869, 3961, 4052, 4142, 4230, 4318
        )
      }
      
      if (parameter == "daily_feed_intake") {
        
        data_selected <- c(
          NA_real_, NA_real_, 16, 20, 24, 27, 31, 35, 39, 44,
          48, 52, 57, 62, 67, 72, 77, 83, 88, 94,
          100, 105, 111, 117, 122, 128, 134, 139, 145, 150,
          156, 161, 166, 171, 176, 180, 185, 189, 193, 197,
          201, 204, 207, 211, 213, 216, 219, 221, 223, 225,
          227, 229, 230, 231, 233, 233, 234
        )
      }
      
      if (parameter == "cum_feed_intake") {
        
        data_selected <- c(
          0, 12, 28, 48, 72, 100, 131, 166, 206, 249,
          297, 349, 406, 468, 535, 608, 685, 768, 856, 950,
          1050, 1155, 1266, 1383, 1505, 1633, 1767, 1907, 2051, 2202,
          2357, 2518, 2684, 2855, 3031, 3211, 3396, 3584, 3777, 3974,
          4175, 4379, 4586, 4797, 5010, 5226, 5445, 5666, 5890, 6115,
          6342, 6571, 6801, 7032, 7265, 7498, 7733
        )
      }
      
      if (parameter == "fcr") {
        
        data_selected <- c(
          NA_real_, 0.196, 0.352, 0.476, 0.577, 0.658, 0.724,
          0.780, 0.826, 0.865, 0.900, 0.930, 0.957, 0.982,
          1.005, 1.026, 1.047, 1.066, 1.086, 1.105,
          1.123, 1.142, 1.160, 1.178, 1.196, 1.214,
          1.233, 1.251, 1.269, 1.288, 1.306, 1.325,
          1.343, 1.362, 1.381, 1.399, 1.418, 1.437,
          1.456, 1.474, 1.493, 1.512, 1.531, 1.550,
          1.569, 1.587, 1.606, 1.625, 1.644, 1.663,
          1.681, 1.700, 1.719, 1.738, 1.756, 1.775, 1.793
        )
      }
    }
    
    # -------------------------------------------------------------------------
    # Ross308 male
    # -------------------------------------------------------------------------
    
    if (sex == "male") {
      
      if (parameter == "bw") {
        
        data_selected <- c(
          44, 62, 80, 101, 124, 150, 180, 213, 249, 288,
          332, 379, 429, 483, 541, 603, 668, 737, 809, 885,
          964, 1046, 1131, 1219, 1310, 1403, 1499, 1597, 1697, 1799,
          1902, 2008, 2114, 2222, 2331, 2441, 2552, 2663, 2774, 2886,
          2998, 3110, 3222, 3333, 3445, 3555, 3665, 3775, 3883, 3991,
          4098, 4203, 4308, 4411, 4513, 4614, 4714
        )
      }
      
      if (parameter == "daily_feed_intake") {
        
        data_selected <- c(
          NA_real_, NA_real_, 15, 19, 23, 27, 31, 35, 40, 44,
          49, 54, 59, 64, 70, 75, 81, 87, 93, 99,
          105, 111, 118, 124, 130, 136, 143, 149, 155, 161,
          167, 173, 178, 184, 189, 195, 200, 204, 209, 214,
          218, 222, 226, 229, 233, 236, 239, 242, 244, 247,
          249, 251, 253, 254, 255, 257, 258
        )
      }
      
      if (parameter == "cum_feed_intake") {
        
        data_selected <- c(
          0, 11, 26, 45, 68, 95, 126, 161, 201, 245,
          295, 348, 408, 472, 542, 617, 698, 785, 878, 977,
          1082, 1193, 1310, 1434, 1564, 1701, 1843, 1992, 2147, 2308,
          2475, 2648, 2826, 3010, 3200, 3394, 3594, 3798, 4007, 4221,
          4439, 4661, 4886, 5116, 5348, 5584, 5823, 6065, 6309, 6556,
          6805, 7055, 7308, 7562, 7817, 8074, 8332
        )
      }
      
      if (parameter == "fcr") {
        
        data_selected <- c(
          NA_real_, 0.181, 0.328, 0.450, 0.549, 0.632, 0.701,
          0.759, 0.808, 0.851, 0.888, 0.920, 0.950, 0.976,
          1.000, 1.023, 1.045, 1.065, 1.085, 1.104,
          1.122, 1.141, 1.159, 1.177, 1.195, 1.212,
          1.230, 1.248, 1.266, 1.283, 1.301, 1.319,
          1.337, 1.355, 1.373, 1.390, 1.408, 1.426,
          1.444, 1.462, 1.481, 1.499, 1.517, 1.535,
          1.553, 1.571, 1.589, 1.607, 1.625, 1.643,
          1.661, 1.679, 1.696, 1.714, 1.732, 1.750, 1.768
        )
      }
    }
  }
  
  # ===========================================================================
  # COBB 500 PERFORMANCE STANDARDS
  # Based on the attached Cobb500 metric performance tables
  # ===========================================================================
  
  if (genetic == "Cobb500") {
    
    # -------------------------------------------------------------------------
    # Cobb500 as-hatched
    # -------------------------------------------------------------------------
    
    if (sex == "as_hatched") {
      
      if (parameter == "bw") {
        
        data_selected <- c(
          42, 55, 71, 90, 112, 138, 168, 202, 240, 283,
          330, 382, 440, 503, 570, 639, 711, 786, 864, 945,
          1029, 1116, 1205, 1296, 1390, 1486, 1583, 1682, 1783, 1886,
          1989, 2094, 2200, 2306, 2413, 2521, 2629, 2738, 2846, 2954,
          3062, 3170, 3278, 3384, 3490, 3595, 3699, 3801, 3902, 4001,
          4099, 4195, 4289, 4380, 4470, 4557, 4641
        )
      }
      
      if (parameter == "daily_feed_intake") {
        
        data_selected <- c(
          NA_real_, NA_real_, NA_real_, NA_real_,
          NA_real_, NA_real_, NA_real_, NA_real_,
          40, 44, 50, 57, 64, 73, 80, 84, 91, 98, 105, 111,
          118, 125, 131, 137, 143, 149, 154, 160, 165, 169,
          174, 178, 183, 187, 191, 194, 198, 202, 206, 209,
          213, 217, 220, 224, 228, 232, 236, 239, 243, 247,
          250, 253, 256, 258, 260, 261, 262
        )
      }
      
      if (parameter == "cum_feed_intake") {
        
        data_selected <- c(
          NA_real_, NA_real_, NA_real_, NA_real_,
          NA_real_, NA_real_, NA_real_,
          180, 220, 264, 314, 371, 435, 508, 588, 672,
          763, 861, 966, 1077, 1195, 1320, 1451, 1588, 1731, 1880,
          2034, 2194, 2359, 2528, 2702, 2880, 3063, 3250, 3441, 3635,
          3833, 4035, 4241, 4450, 4663, 4880, 5100, 5324, 5552, 5784,
          6020, 6259, 6502, 6749, 6999, 7252, 7508, 7766, 8026, 8287,
          8549
        )
      }
      
      if (parameter == "fcr") {
        
        data_selected <- c(
          NA_real_, NA_real_, NA_real_, NA_real_,
          NA_real_, NA_real_, NA_real_,
          0.891, 0.917, 0.933, 0.952, 0.971, 0.991, 1.012,
          1.029, 1.050, 1.072, 1.094, 1.116, 1.138,
          1.160, 1.182, 1.203, 1.224, 1.245, 1.265,
          1.284, 1.303, 1.322, 1.340, 1.358, 1.375,
          1.392, 1.409, 1.425, 1.441, 1.457, 1.474,
          1.490, 1.506, 1.522, 1.539, 1.555, 1.573,
          1.590, 1.608, 1.627, 1.646, 1.666, 1.686,
          1.707, 1.728, 1.750, 1.772, 1.795, 1.818, 1.842
        )
      }
    }
    
    # -------------------------------------------------------------------------
    # Cobb500 female
    # -------------------------------------------------------------------------
    
    if (sex == "female") {
      
      if (parameter == "bw") {
        
        data_selected <- c(
          42, 54, 70, 88, 110, 135, 165, 199, 236, 276,
          320, 369, 421, 478, 537, 601, 667, 737, 810, 885,
          963, 1043, 1126, 1210, 1297, 1386, 1477, 1569, 1662, 1757,
          1853, 1951, 2049, 2148, 2248, 2348, 2448, 2549, 2650, 2751,
          2852, 2952, 3052, 3151, 3250, 3348, 3445, 3540, 3635, 3728,
          3819, 3909, 3997, 4083, 4167, 4249, 4329
        )
      }
      
      if (parameter == "daily_feed_intake") {
        
        data_selected <- c(
          NA_real_, NA_real_, NA_real_, NA_real_,
          NA_real_, NA_real_, NA_real_, NA_real_,
          40, 42, 48, 54, 60, 67, 72, 80, 86, 93, 99, 106,
          112, 118, 124, 130, 136, 141, 146, 151, 156, 161,
          165, 169, 173, 177, 181, 185, 188, 192, 196, 199,
          203, 207, 210, 214, 218, 222, 226, 230, 234, 238,
          242, 245, 249, 252, 254, 256, 257
        )
      }
      
      if (parameter == "cum_feed_intake") {
        
        data_selected <- c(
          NA_real_, NA_real_, NA_real_, NA_real_,
          NA_real_, NA_real_, NA_real_,
          176, 216, 258, 306, 360, 420, 487, 559, 639,
          725, 818, 917, 1023, 1135, 1253, 1377, 1507, 1643, 1784,
          1930, 2081, 2237, 2398, 2563, 2732, 2905, 3082, 3263, 3448,
          3636, 3828, 4024, 4223, 4426, 4633, 4843, 5057, 5275, 5497,
          5723, 5953, 6187, 6425, 6667, 6912, 7161, 7413, 7667, 7923,
          8180
        )
      }
      
      if (parameter == "fcr") {
        
        data_selected <- c(
          NA_real_, NA_real_, NA_real_, NA_real_,
          NA_real_, NA_real_, NA_real_,
          0.884, 0.915, 0.935, 0.956, 0.976, 0.998, 1.019,
          1.041, 1.063, 1.086, 1.109, 1.132, 1.155,
          1.178, 1.200, 1.222, 1.244, 1.265, 1.286,
          1.306, 1.326, 1.346, 1.364, 1.383, 1.400,
          1.418, 1.435, 1.452, 1.469, 1.486, 1.502,
          1.519, 1.535, 1.552, 1.570, 1.587, 1.605,
          1.623, 1.642, 1.662, 1.682, 1.703, 1.724,
          1.746, 1.769, 1.792, 1.816, 1.840, 1.865, 1.890
        )
      }
    }
    
    # -------------------------------------------------------------------------
    # Cobb500 male
    # -------------------------------------------------------------------------
    
    if (sex == "male") {
      
      if (parameter == "bw") {
        
        data_selected <- c(
          42, 56, 72, 92, 114, 141, 171, 205, 244, 289,
          339, 395, 457, 525, 603, 677, 754, 834, 918, 1005,
          1095, 1188, 1284, 1382, 1482, 1585, 1690, 1796, 1904, 2014,
          2125, 2237, 2350, 2464, 2579, 2694, 2810, 2926, 3042, 3158,
          3274, 3389, 3503, 3617, 3730, 3842, 3952, 4062, 4169, 4275,
          4379, 4481, 4580, 4677, 4772, 4864, 4953
        )
      }
      
      if (parameter == "daily_feed_intake") {
        
        data_selected <- c(
          NA_real_, NA_real_, NA_real_, NA_real_,
          NA_real_, NA_real_, NA_real_, NA_real_,
          40, 45, 52, 60, 68, 78, 90, 89, 96, 103, 110, 117,
          124, 131, 138, 144, 151, 157, 162, 168, 173, 178,
          183, 188, 192, 196, 200, 204, 208, 212, 215, 219,
          223, 226, 230, 234, 237, 241, 245, 248, 252, 255,
          258, 261, 263, 265, 266, 266, 266
        )
      }
      
      if (parameter == "cum_feed_intake") {
        
        data_selected <- c(
          NA_real_, NA_real_, NA_real_, NA_real_,
          NA_real_, NA_real_, NA_real_,
          182, 222, 267, 319, 379, 447, 525, 615, 704,
          800, 903, 1013, 1130, 1254, 1385, 1523, 1667, 1818, 1975,
          2137, 2305, 2478, 2656, 2839, 3027, 3219, 3415, 3615, 3819,
          4027, 4239, 4454, 4673, 4896, 5122, 5352, 5586, 5823, 6064,
          6309, 6557, 6809, 7064, 7322, 7583, 7846, 8111, 8377, 8643,
          8909
        )
      }
      
      if (parameter == "fcr") {
        
        data_selected <- c(
          NA_real_, NA_real_, NA_real_, NA_real_,
          NA_real_, NA_real_, NA_real_,
          0.883, 0.906, 0.920, 0.938, 0.957, 0.976, 0.998,
          1.018, 1.039, 1.060, 1.081, 1.102, 1.124,
          1.145, 1.166, 1.186, 1.206, 1.226, 1.246,
          1.265, 1.283, 1.301, 1.319, 1.336, 1.353,
          1.369, 1.386, 1.402, 1.417, 1.433, 1.449,
          1.464, 1.480, 1.496, 1.512, 1.528, 1.544,
          1.561, 1.579, 1.597, 1.615, 1.633, 1.653,
          1.672, 1.693, 1.713, 1.734, 1.755, 1.777, 1.799
        )
      }
    }
  }
  
  # ---------------------------------------------------------------------------
  # Final internal check
  # ---------------------------------------------------------------------------
  
  if (!exists("data_selected", inherits = FALSE)) {
    stop(
      "No performance data were found for the requested combination."
    )
  }
  
  # Calculate and return the requested performance value
  return(calc_value(age, data_selected))
}


