--[[
CollectibleHelper by aaronlink127 v1.08 (for GTA Online v1.67)
    Shows blips on the map for the following collectibles
    - SP
      - Letter Scraps
      - Spaceship Parts
    - MP
      - Action Figures
      - Playing Cards
      - Signal Jammers
      - Los Santos Slasher Clues
      - Movie Props (exterior only)
      - Jack O' Lanterns
      - LD Organics Product
      - Snowmen
      - Ghosts Exposed
      - Peyote Plants
]]--
util.require_natives("3095a")

local function spoof_main(fn, ...)
    local ret
    local args = {...}
    util.spoof_script("main_persistent", function()
        ret = {fn(table.unpack(args))}
    end)
    return table.unpack(ret)
end
local function add_blip_for_coord(x, y, z)
    return spoof_main(HUD.ADD_BLIP_FOR_COORD, x, y, z)
end
local function remove_blip(blip)
    spoof_main(util.remove_blip, blip)
end
local tunable_collectables_ld_organics, tunable_collectables_trick_or_treat, tunable_collectables_snowmen
util.create_thread(function()
    tunable_collectables_ld_organics = memory.tunable_offset("collectables_ld_organics")
    tunable_collectables_trick_or_treat = memory.tunable_offset("collectables_trick_or_treat")
    tunable_collectables_snowmen = memory.tunable_offset("collectables_snowmen")
    tunable_vc_peyote_enable = memory.tunable_offset("vc_peyote_enable")
    tunable_vc_peyote_disable_1 = memory.tunable_offset("vc_peyote_disable_1")
    tunable_vc_peyote_disable_2 = memory.tunable_offset("vc_peyote_disable_2")
    tunable_vc_peyote_disable_3 = memory.tunable_offset("vc_peyote_disable_3")
    tunable_vc_peyote_disable_4 = memory.tunable_offset("vc_peyote_disable_4")
    tunable_vc_peyote_disable_5 = memory.tunable_offset("vc_peyote_disable_5")
    tunable_vc_peyote_disable_6 = memory.tunable_offset("vc_peyote_disable_6")
    tunable_vc_peyote_disable_7 = memory.tunable_offset("vc_peyote_disable_7")
    tunable_vc_peyote_disable_8 = memory.tunable_offset("vc_peyote_disable_8")
    tunable_vc_peyote_disable_9 = memory.tunable_offset("vc_peyote_disable_9")
    tunable_vc_peyote_disable_10 = memory.tunable_offset("vc_peyote_disable_10")
    tunable_vc_peyote_disable_11 = memory.tunable_offset("vc_peyote_disable_11")
    tunable_vc_peyote_disable_12 = memory.tunable_offset("vc_peyote_disable_12")
    tunable_vc_peyote_disable_13 = memory.tunable_offset("vc_peyote_disable_13")
    tunable_vc_peyote_disable_14 = memory.tunable_offset("vc_peyote_disable_14")
    tunable_vc_peyote_disable_15 = memory.tunable_offset("vc_peyote_disable_15")
end)
local tunableBase<const> = 262145
local function readTunableBool(idx)
    return memory.read_int(memory.script_global(tunableBase+idx)) ~= 0
end
local tunable_ld

local letterscraps = {}
setmetatable(letterscraps, {
    __index=function(self, idx)
        local sl = memory.script_local("letterScraps", 55 + 1 + (idx - 1) * 11 + 3)
        if sl == 0 then
            return v3()
        end
        return v3(sl)
    end,
    __len=function(self)
        return 50
    end
})
local spaceshipparts = {}
setmetatable(spaceshipparts, {
    __index=function(self, idx)
        local sl = memory.script_local("spaceshipParts", 53 + 1 + (idx - 1) * 11 + 3)
        if sl == 0 then
            return v3()
        end
        return v3(sl)
    end,
    __len=function(self)
        return 50
    end
})
local peyotes = {
    v3(171.4769, -1925.586, 20.156),
    v3(-234.541, -1516.663, 31.296),
    v3(-213.5869, 6455.24, 30.329),
    v3(327.064, 6430.808, 30.097),
    v3(2268.018, 4597.53, 34.175),
    v3(3102.362, 6034.412, 122.219),
    v3(-35.2434, 2868.4, 58.4023),
    v3(1733.005, 3850.126, 33.874),
    v3(340.023, 3565.621, 32.491),
    v3(-1858.733, 4806.635, 1.969),
    v3(490.588, 5530.081, 777.292),
    v3(-2792.443, 1432.48, 99.968),
    v3(-2999.09, 769.195, 26.167),
    v3(-855.473, 572.053, 95.69),
    v3(1021.663, 2910.82, 39.645),
    v3(-3078.123, 3202.819, 1.319),
    v3(-1557.408, 2581.642, -0.078),
    v3(2578.658, 5548.083, 59.436),
    v3(2573.032, 1250.679, 42.545),
    v3(-922.265, 4583.207, 230.673),
    v3(2820.144, -759.318, 1.471),
    v3(2385.41, 3335.046, 46.401),
    v3(-1275.095, 1895.234, 101.362),
    v3(1545.851, 1685.537, 108.875),
    v3(727.608, -235.347, 65.276),
    v3(-111.254, -413.31, 34.65),
    v3(-1881.692, -607.578, 14.588),
    v3(1071.716, -686.215, 56.692),
    v3(2066.84, 1940.29, 81.791),
    v3(1614.594, 6611.073, 14.617),
    v3(-1179.712, 3854.412, 488.493),
    v3(2940.191, 2745.018, 42.231),
    v3(1288.918, -1059.638, 38.242),
    v3(-1678.225, 357.721, 83.711),
    v3(-778.6017, 117.243, 55.456),
    v3(-794.2935, -727.5123, 26.418),
    v3(330.147, 440.902, 144.37),
    v3(-1314.857, -424.843, 34.462),
    v3(224.4638, 49.089, 83.1668),
    v3(1276.405, -1720.52, 53.795),
    v3(-960.924, -2034.23, 8.524),
    v3(-838.726, -1216.943, 5.902),
    v3(2029.585, 498.1133, 163.1716),
    v3(2764.432, -1600.286, 0.865),
    v3(1498.68, -2722.499, 1.933),
    v3(217.1979, -980.8727, 28.7917),
    v3(686.64, -1109.484, 21.477),
    v3(-220.848, 1006.557, 231.478),
    v3(493.725, 1439.799, 350.758),
    v3(-995.688, 6258.749, 1.433),
    v3(-2871.632, 2605.268, -10.2517),
    v3(56.2666, 7365.265, -5.357),
    v3(-2861.12, 3900.557, -33.818),
    v3(-1588.691, 5312.984, -5.1802),
    v3(475.3864, 6946.059, -7.333),
    v3(2453.258, 6692.051, -14.2188),
    v3(4235.621, 4105.97, -31.4225),
    v3(-138.1969, 4060.704, 26.1655),
    v3(3395.229, 2252.51, -14.6511),
    v3(2946.109, 812.0292, -11.0387),
    v3(3194.644, -356.9405, -33.105),
    v3(-1745.945, -1277.373, -19.8266),
    v3(-3320.881, 1335.263, -17.2728),
    v3(2183.961, -2714.103, -29.2357),
    v3(-169.7448, -2890.406, -24.8927),
    v3(-164.6574, -2309.281, -29.0637),
    v3(618.835, -2192.552, -8.5744),
    v3(649.5286, -3232.574, -16.81),
    v3(-3078.018, -104.2799, -18.3237),
    v3(-2205.006, -681.4622, -10.409),
    v3(825.2657, -2790.566, -22.1959),
    v3(3415.271, 5253.468, -12.1134),
    v3(1219.192, 4119.479, 13.7925),
    v3(-1014.588, -1707.169, -9.2745),
    v3(1674.983, 5141.897, 149.6046),
    v3(-21.0273, -1424.168, 29.7078),
}
local figures = {
    v3(-2557.405, 2315.502, 33.742),
    v3(2487.128, 3759.327, 42.317),
    v3(457.198, 5573.861, 780.184),
    v3(-1280.407, 2549.743, 17.534),
    v3(-107.722, -856.981, 38.261),
    v3(-1050.513, -522.612, 36.634),
    v3(693.306, 1200.583, 344.524),
    v3(2500.654, -389.482, 94.245),
    v3(483.4, -3110.621, 6.627),
    v3(-2169.277, 5192.986, 16.295),
    v3(177.674, 6394.054, 31.376),
    v3(2416.942, 4994.557, 45.239),
    v3(1702.9, 3291, 48.72),
    v3(-600.813, 2088.011, 132.336),
    v3(-3019.793, 41.9486, 10.2924),
    v3(-485.4648, -54.441, 38.9945),
    v3(-1350.785, -1547.089, 4.675),
    v3(379.535, -1509.398, 29.34),
    v3(2548.713, 385.386, 108.423),
    v3(-769.346, 877.307, 203.424),
    v3(-1513.54, 1517.184, 111.305),
    v3(-1023.899, 190.912, 61.282),
    v3(1136.355, -666.404, 57.044),
    v3(3799.76, 4473.048, 6.032),
    v3(1243.588, -2572.136, 42.603),
    v3(219.811, 97.162, 96.336),
    v3(-1545.826, -449.397, 40.318),
    v3(-928.683, -2938.691, 13.059),
    v3(-1647.926, -1094.716, 12.736),
    v3(-2185.939, 4249.814, 48.803),
    v3(-262.339, 4729.229, 137.329),
    v3(-311.701, 6315.024, 31.978),
    v3(3306.444, 5194.742, 17.432),
    v3(1389.886, 3608.834, 35.06),
    v3(852.846, 2166.327, 52.717),
    v3(-1501.96, 814.071, 181.433),
    v3(2634.972, 2931.061, 44.608),
    v3(660.57, 549.947, 129.157),
    v3(-710.626, -905.881, 19.015),
    v3(1207.701, -1479.537, 35.166),
    v3(-90.151, 939.849, 232.515),
    v3(-180.059, -631.866, 48.534),
    v3(-299.634, 2847.173, 55.485),
    v3(621.365, -409.254, -1.308),
    v3(-988.92, -102.669, 40.157),
    v3(63.999, 3683.868, 39.763),
    v3(-688.668, 5829.006, 16.775),
    v3(1540.435, 6323.453, 23.519),
    v3(2725.806, 4142.14, 43.293),
    v3(1297.977, 4306.744, 37.897),
    v3(1189.579, 2641.222, 38.413),
    v3(-440.796, 1596.48, 358.648),
    v3(-2237.557, 249.282, 175.352),
    v3(-1211.932, -959.965, 0.393),
    v3(153.845, -3077.341, 6.744),
    v3(-66.231, -1451.825, 31.164),
    v3(987.982, -136.863, 73.454),
    v3(-507.032, 393.905, 96.411),
    v3(172.1275, -564.1393, 22.145),
    v3(1497.202, -2133.147, 76.302),
    v3(-2958.706, 386.41, 14.434),
    v3(1413.963, 1162.483, 114.351),
    v3(-1648.058, 3018.313, 31.25),
    v3(-1120.2, 4977.292, 185.445),
    v3(1310.683, 6545.917, 4.798),
    v3(1714.573, 4790.844, 41.539),
    v3(1886.644, 3913.758, 32.039),
    v3(543.476, 3074.79, 40.324),
    v3(1408.045, 2157.34, 97.575),
    v3(-3243.858, 996.179, 12.486),
    v3(-1905.566, -709.6311, 8.766),
    v3(-1462.089, 182.089, 54.953),
    v3(86.997, 812.619, 211.062),
    v3(-886.554, -2096.579, 8.699),
    v3(367.684, -2113.475, 16.274),
    v3(679.009, -1522.824, 8.834),
    v3(1667.377, 0.119, 165.118),
    v3(-293.486, -342.485, 9.481),
    v3(462.664, -765.675, 26.358),
    v3(-57.784, 1939.74, 189.655),
    v3(2618.411, 1692.395, 31.9462),
    v3(-1894.554, 2043.517, 140.9093),
    v3(2221.858, 5612.785, 54.0631),
    v3(-551.3712, 5330.728, 73.9861),
    v3(-2171.406, 3441.188, 32.175),
    v3(1848.131, 2700.702, 63.008),
    v3(-1719.602, -232.886, 54.4441),
    v3(-55.3785, -2519.755, 7.2875),
    v3(874.8454, -2163.998, 32.3688),
    v3(-43.6983, -1747.961, 29.2778),
    v3(173.324, -1208.43, 29.6564),
    v3(2936.323, 4620.483, 48.767),
    v3(3514.655, 3754.687, 34.4766),
    v3(656.9, -1046.931, 21.5745),
    v3(-141.1536, 234.8366, 99.0008),
    v3(-1806.68, 427.6159, 131.765),
    v3(-908.9565, -1148.917, 2.3868),
    v3(387.9323, 2570.408, 43.299),
    v3(2399.505, 3062.746, 53.4703),
    v3(2394.721, 3062.689, 51.2379),
}
local jammers = {
    v3(1006.372, -2881.68, 30.422),
    v3(-980.242, -2637.703, 88.528),
    v3(-688.195, -1399.329, 23.331),
    v3(1120.696, -1539.165, 54.871),
    v3(2455.134, -382.585, 112.635),
    v3(793.878, -717.299, 48.083),
    v3(-168.3, -590.153, 210.936),
    v3(-1298.343, -435.8369, 108.129),
    v3(-2276.484, 335.0941, 195.723),
    v3(-667.25, 228.545, 154.051),
    v3(682.561, 567.5302, 153.895),
    v3(2722.561, 1538.103, 85.202),
    v3(758.539, 1273.687, 445.181),
    v3(-3079.258, 768.5189, 31.569),
    v3(-2359.338, 3246.831, 104.188),
    v3(1693.732, 2656.602, 60.84),
    v3(3555.018, 3684.98, 61.27),
    v3(1869.022, 3714.435, 117.068),
    v3(2902.552, 4324.699, 101.106),
    v3(-508.6141, 4426.661, 87.511),
    v3(-104.417, 6227.278, 63.696),
    v3(1607.501, 6437.315, 32.162),
    v3(2792.933, 5993.922, 366.867),
    v3(1720.613, 4822.467, 59.7),
    v3(-1661.01, -1126.742, 29.773),
    v3(-1873.49, 2058.357, 154.407),
    v3(2122.46, 1750.886, 138.114),
    v3(-417.424, 1153.143, 339.128),
    v3(3303.901, 5169.792, 28.735),
    v3(-1005.848, 4852.147, 302.025),
    v3(-306.627, 2824.859, 69.512),
    v3(1660.663, -28.07, 179.137),
    v3(754.647, 2584.067, 133.904),
    v3(-279.9081, -1915.608, 54.173),
    v3(-260.4421, -2411.807, 126.019),
    v3(552.132, -2221.853, 73),
    v3(394.3919, -1402.144, 76.267),
    v3(1609.791, -2243.767, 130.187),
    v3(234.2919, 220.771, 168.981),
    v3(-1237.121, -850.4969, 82.98),
    v3(-1272.732, 317.9532, 90.352),
    v3(0.088, -1002.404, 96.32),
    v3(470.5569, -105.049, 135.908),
    v3(-548.5471, -197.9911, 82.813),
    v3(2581.047, 461.9421, 115.095),
    v3(720.14, 4097.634, 38.075),
    v3(1242.471, 1876.068, 92.242),
    v3(2752.113, 3472.779, 67.911),
    v3(-2191.856, 4292.408, 55.013),
    v3(450.475, 5581.514, 794.0683),
}
local cards = {
    v3(1992.183, 3046.28, 47.125),
    v3(120.38, -1297.669, 28.705),
    v3(79.293, 3704.578, 40.945),
    v3(2937.738, 5325.846, 100.176),
    v3(727.153, 4189.818, 40.476),
    v3(-103.14, 369.008, 112.267),
    v3(99.959, 6619.539, 32.314),
    v3(-282.6689, 6226.274, 31.3554),
    v3(1707.556, 4921.021, 41.865),
    v3(-1581.86, 5204.295, 3.9093),
    v3(10.8264, -1101.157, 29.613),
    v3(1690.043, 3589.014, 35.5883),
    v3(1159.144, -316.5876, 69.5134),
    v3(2341.807, 2571.737, 47.6079),
    v3(-3048.193, 585.2986, 7.7708),
    v3(-3149.707, 1115.83, 20.7216),
    v3(-1840.641, -1235.319, 13.2937),
    v3(810.6056, -2978.741, 5.8116),
    v3(202.2747, -1645.225, 29.7679),
    v3(253.2056, 215.9778, 106.2848),
    v3(-1166.183, -233.9277, 38.262),
    v3(729.9886, 2514.713, 73.1663),
    v3(188.1851, 3076.332, 43.0447),
    v3(3687.914, 4569.073, 24.9397),
    v3(1876.975, 6410.034, 46.5982),
    v3(2121.146, 4784.687, 40.8114),
    v3(900.0845, 3558.156, 33.6258),
    v3(2695.272, 4324.496, 45.6516),
    v3(-1829.428, 798.4049, 138.0583),
    v3(-1203.725, -1558.866, 4.1736),
    v3(-73.2829, -2005.476, 18.2561),
    v3(-1154.201, -527.2959, 31.7117),
    v3(990.0786, -1800.391, 31.3781),
    v3(827.5513, -2158.744, 29.417),
    v3(-1512.08, -103.625, 54.2027),
    v3(-970.7493, 104.3396, 55.0431),
    v3(-428.6815, 1213.905, 325.9329),
    v3(-167.8387, -297.1122, 39.0353),
    v3(2747.322, 3465.12, 55.6336),
    v3(-1103.659, 2714.689, 19.4539),
    v3(549.4841, -189.3053, 54.4369),
    v3(-1287.689, -1118.818, 6.3057),
    v3(1131.428, -982.0297, 46.6521),
    v3(-1028.083, -2746.936, 13.3589),
    v3(-538.5779, -1278.542, 26.3437),
    v3(1326.449, -1651.263, 52.0964),
    v3(183.3252, -685.2661, 42.607),
    v3(1487.846, 1129.2, 114.3005),
    v3(-2305.538, 3387.973, 31.0201),
    v3(-522.632, 4193.459, 193.7517),
    v3(-748.9897, 5599.534, 41.5794),
    v3(-288.0628, 2545.21, 74.4223),
    v3(2565.326, 296.8703, 108.7367),
    v3(-408.2484, 585.783, 124.378),
}
local movie_prop = {
    v3(94.202, -1294.965, 29.067),
    v3(-1010.051, -502.175, 36.493),
    v3(2517.254, 3789.326, 53.698),
    v3(-2349.036, 3270.785, 32.968),
    v3(1165.416, 247.5531, -50.73),
    v3(-41.795, 2873.231, 59.625),
    v3(-1169.573, 4926.988, 223.7279),
}
local lanterns = {
    v3(-189.701, -763.3126, 29.454),
    v3(-233.321, -909.614, 31.3158),
    v3(-553.5505, -815.0607, 29.6916),
    v3(-728.8868, -678.7939, 29.315),
    v3(-1185.507, -566.7111, 27.3348),
    v3(-1339.806, -409.658, 35.373),
    v3(-1536.558, -423.9365, 34.597),
    v3(-1580.622, -952.5058, 12.0174),
    v3(-1976.58, -532.485, 10.826),
    v3(-1884.625, -366.126, 48.354),
    v3(-1289.285, -1115.446, 6.0404),
    v3(-1503.121, -936.5198, 9.1563),
    v3(-1334.734, -1280.177, 3.836),
    v3(-1183.44, -1559.434, 3.3591),
    v3(-971.0191, -1093.48, 1.1503),
    v3(-840.8212, -1207.88, 5.6051),
    v3(-296.9001, -1334.173, 30.2995),
    v3(-225.556, -1500.448, 31.131),
    v3(-121.627, -1489.878, 32.821),
    v3(-195.651, -1607.897, 33.0368),
    v3(-160.142, -1681.59, 35.964),
    v3(-81.4956, -1642.043, 28.3083),
    v3(-20.704, -1856.823, 24.016),
    v3(23.953, -1897.309, 21.969),
    v3(151.071, -1865.461, 23.205),
    v3(177.9339, -1927.648, 20.0126),
    v3(224.824, -2036.894, 17.38),
    v3(325.4174, -1946.595, 23.7789),
    v3(386.328, -1880.668, 25.035),
    v3(321.5227, -1758.72, 28.3096),
    v3(496.8552, -1819.122, 27.501),
    v3(430.3069, -1724.543, 28.6064),
    v3(413.243, -1487.521, 29.152),
    v3(376.6, -2067.951, 20.369),
    v3(297.152, -2096.86, 16.667),
    v3(1257.384, -1762.429, 48.662),
    v3(1310.985, -1698.068, 56.836),
    v3(1203.222, -1672.258, 41.356),
    v3(1296.15, -1619.214, 53.224),
    v3(1231.962, -1590.563, 52.769),
    v3(1152.695, -1531.528, 34.3815),
    v3(1184.524, -1464.062, 33.823),
    v3(1320.342, -1557.638, 50.2518),
    v3(1435.174, -1491.414, 62.625),
    v3(806.0478, -1073.288, 27.924),
    v3(847.3984, -1021.431, 26.536),
    v3(477.993, -976.005, 26.982),
    v3(387.744, -973.043, 28.437),
    v3(359.719, -1072.742, 28.545),
    v3(262.8465, -1026.979, 28.2158),
    v3(244.76, -1073.888, 28.287),
    v3(1209.887, -1388.977, 34.3769),
    v3(1142.299, -981.9567, 45.1429),
    v3(73.529, -1026.593, 28.475),
    v3(68.017, -960.636, 28.807),
    v3(-16.947, -979.452, 28.503),
    v3(-1205.765, -1135.791, 6.8417),
    v3(-1124.566, -1089.562, 1.549),
    v3(-1075.785, -1027.721, 3.548),
    v3(-961.535, -940.509, 1.149),
    v3(-1028.67, -920.2025, 4.0462),
    v3(-1150.722, -990.091, 1.149),
    v3(-1726.561, -192.421, 57.511),
    v3(-62.999, -1450.793, 31.1237),
    v3(-1548.042, -90.522, 53.933),
    v3(-1465.655, -31.124, 53.696),
    v3(-1475.253, 63.768, 52.328),
    v3(-1565.532, 40.189, 57.883),
    v3(-1650.799, 150.181, 61.167),
    v3(-1538.653, 130.704, 56.37),
    v3(-1179.64, 292.144, 68.497),
    v3(-1023.641, 358.387, 70.36),
    v3(-1131.724, 390.5965, 69.8053),
    v3(-1214.895, 461.5896, 90.8536),
    v3(-1499.284, 523.861, 117.271),
    v3(-1290.108, 648.5641, 140.4938),
    v3(-1123.263, 575.838, 103.394),
    v3(-1025.834, 505.1749, 80.6515),
    v3(-969.444, 434.741, 79.57),
    v3(-864.8736, 389.6919, 86.4873),
    v3(-819.564, 266.954, 85.392),
    v3(-597.9922, 278.1837, 81.1112),
    v3(-571.93, 401.957, 99.665),
    v3(-585.74, 494.794, 106.106),
    v3(-718.91, 490.583, 108.388),
    v3(-884.518, 519.033, 91.441),
    v3(-937.445, 591.477, 100.499),
    v3(-702.494, 589.252, 140.929),
    v3(-888.666, 699.998, 149.6837),
    v3(-1019.008, 718.9766, 162.9962),
    v3(-1163.977, 729.633, 154.61),
    v3(-578.299, 734.835, 183.03),
    v3(-549.275, 826.159, 196.508),
    v3(-493.592, 739.668, 162.035),
    v3(-447.063, 685.288, 151.955),
    v3(-344.611, 624.076, 170.355),
    v3(-247.952, 622.206, 186.809),
    v3(-137.8688, 592.7097, 203.5206),
    v3(-178.251, 502.183, 135.827),
    v3(-353.838, 467.898, 111.6),
    v3(-370.018, 343.79, 108.946),
    v3(-250.332, 397.556, 110.251),
    v3(-85.666, 424.562, 112.224),
    v3(-822.3367, 813.652, 199.8532),
    v3(-1313.372, 451.3146, 99.9888),
    v3(-1686.279, -290.491, 50.892),
    v3(82.5397, -91.9352, 59.5567),
    v3(124.799, 66.057, 78.74),
    v3(12.9173, -8.399, 69.1162),
    v3(-176.8698, 86.8545, 69.2855),
    v3(-438.5465, -67.3735, 42.0095),
    v3(-375.576, 44.577, 53.428),
    v3(-569.9086, 168.254, 65.5663),
    v3(1775.932, 3740.67, 33.6562),
    v3(1915.427, 3825.728, 31.443),
    v3(2002.334, 3780.291, 31.179),
    v3(1923.412, 3916.096, 31.5573),
    v3(1759.466, 3870.604, 33.7011),
    v3(1661.887, 3822.058, 34.473),
    v3(1419.643, 3668.236, 38.7334),
    v3(439.621, 3571.637, 32.237),
    v3(247.488, 3167.516, 41.885),
    v3(197.3604, 3030.443, 42.8867),
    v3(-286.359, 2838.471, 53.973),
    v3(-325.2867, 2816.483, 58.4498),
    v3(-461.6427, 2859.427, 33.7354),
    v3(-37.136, 2869.897, 58.625),
    v3(470.221, 2607.623, 43.481),
    v3(563.666, 2599.943, 42.113),
    v3(733.646, 2524.984, 72.34),
    v3(721.333, 2331.018, 50.754),
    v3(789.176, 2180.511, 51.652),
    v3(843.259, 2113.888, 51.267),
    v3(1531.942, 1729.31, 108.9177),
    v3(2588.599, 3167.521, 50.371),
    v3(2618.848, 3280.744, 54.249),
    v3(2985.01, 3482.104, 70.4419),
    v3(1356.303, 1147.111, 112.759),
    v3(1533.893, 2219.883, 76.2135),
    v3(-148.0881, 287.3474, 95.804),
    v3(1989.794, 3054.594, 46.213),
    v3(2166.818, 3381.051, 45.46),
    v3(2180.096, 3497.361, 44.4592),
    v3(2418.844, 4021.485, 35.802),
    v3(346.24, 441.64, 146.706),
    v3(325.772, 536.228, 152.811),
    v3(216.718, 621.505, 186.634),
    v3(167.685, 487.5329, 142.1009),
    v3(57.1598, 451.9345, 145.9096),
    v3(8.554, 542.77, 174.827),
    v3(-148.985, 996.5, 235.885),
    v3(-2006.675, 445.9337, 102.021),
    v3(-1975.162, 629.493, 121.535),
    v3(-1812.335, 342.8018, 87.9612),
    v3(-1963.542, 246.943, 85.567),
    v3(-340.031, 6165.106, 30.663),
    v3(-404.723, 6316.063, 27.943),
    v3(-305.281, 6329.808, 31.4893),
    v3(-245.486, 6413.258, 30.261),
    v3(-110.0724, 6460.96, 30.6408),
    v3(-48.2033, 6580.343, 31.1805),
    v3(56.455, 6643.994, 31.28),
    v3(-103.7947, 6315.484, 30.5812),
    v3(2232.981, 5611.867, 53.9195),
    v3(1856.438, 3683.872, 33.2675),
    v3(3312.502, 5176.144, 18.6196),
    v3(1662.391, 4775.14, 41.006),
    v3(1724.588, 4643.431, 42.8755),
    v3(1968.356, 4622.632, 40.083),
    v3(1309.106, 4362.913, 40.5463),
    v3(722.405, 4186.963, 39.886),
    v3(92.067, 3743.533, 38.623),
    v3(33.199, 3668.209, 38.715),
    v3(-267.7338, 2628.924, 60.8669),
    v3(-263.6633, 2197.269, 129.4037),
    v3(749.868, 224.827, 86.426),
    v3(133.2061, -567.3676, 42.8161),
    v3(-1874.804, 2030.164, 138.7318),
    v3(-1114.113, 2689.189, 17.5833),
    v3(-3184.543, 1293.391, 13.5473),
    v3(-3205.871, 1151.494, 8.6673),
    v3(-3233.165, 933.7818, 16.1599),
    v3(-2997.617, 695.5018, 24.7621),
    v3(-3036.497, 491.4613, 5.7679),
    v3(-3087.551, 220.9675, 13.0732),
    v3(-769.6445, 5514.033, 33.8517),
    v3(1706.973, 6425.33, 31.7671),
    v3(2452.608, 4964.704, 45.581),
    v3(2638.939, 4245.413, 43.7446),
    v3(964.9565, -545.2515, 58.3475),
    v3(961.9368, -596.4669, 58.9027),
    v3(997.1859, -728.1738, 56.8192),
    v3(1207.301, -621.1257, 65.4421),
    v3(1371.074, -555.7357, 73.6891),
    v3(1323.79, -583.4503, 72.2514),
    v3(1261.874, -428.6422, 68.8054),
    v3(1011.482, -424.2754, 63.9561),
    v3(-2553.464, 1914.783, 168.0181),
    v3(3688.297, 4563.858, 24.1865),
    v3(-1523.871, 852.2529, 180.5948)
}
local ld_product = {
    v3(-1002.254, 130.075, 55.519),
    v3(-1504.595, -36.351, 54.707),
    v3(-1677.41, -443.6646, 39.8968),
    v3(-842.328, -345.95, 38.501),
    v3(-430.64, 288.196, 86.174),
    v3(1575.068, -1732.029, 87.9448),
    v3(-2038.497, 539.83, 109.752),
    v3(-2973.772, 20.3182, 7.4278),
    v3(-3235.982, 1104.414, 2.602),
    v3(-2630.007, 1874.927, 160.251),
    v3(-1875.84, 2027.968, 139.838),
    v3(-1596.847, 3054.303, 33.12),
    v3(1740.868, 3327.709, 41.211),
    v3(1323.174, 3008.294, 44.09),
    v3(1766.628, 3916.891, 34.821),
    v3(2704.12, 3521.006, 61.773),
    v3(3608.93, 3625.699, 40.827),
    v3(2141.796, 4790.276, 40.7243),
    v3(439.911, 6455.761, 36.068),
    v3(1444.224, 6331.349, 23.806),
    v3(-581.923, 5368.024, 70.294),
    v3(497.611, 5606.312, 795.85),
    v3(1384.78, 4288.897, 36.391),
    v3(712.585, 4111.207, 31.65),
    v3(325.916, 4429.151, 64.688),
    v3(-214.4409, 3601.96, 61.6145),
    v3(66.001, 3760.242, 39.943),
    v3(98.651, 3601.149, 39.752),
    v3(-1147.729, 4949.988, 221.278),
    v3(-2511.306, 3613.96, 13.469),
    v3(-1936.931, 3329.973, 33.215),
    v3(2497.993, -429.74, 93.2676),
    v3(3818.776, 4488.587, 4.532),
    v3(96.5449, -255.7652, 47.0503),
    v3(-1393.931, -1445.899, 4.308),
    v3(-929.642, -746.513, 19.752),
    v3(154.263, 1098.689, 231.338),
    v3(2982.726, 6368.5, 2.311),
    v3(-512.5049, -1626.817, 17.4995),
    v3(-56.232, 80.423, 71.868),
    v3(431.973, -2910.015, 6.734),
    v3(664.98, 1284.782, 360.1198),
    v3(-452.9, 1079.414, 327.803),
    v3(-196.239, -2354.753, 9.478),
    v3(248.439, 128.028, 103.099),
    v3(2661.16, 1640.974, 24.654),
    v3(1668.438, -26.473, 184.91),
    v3(-37.931, 1937.999, 189.8),
    v3(-1591.535, 801.656, 186.161),
    v3(2193.213, 5593.691, 53.684),
    v3(1641.563, 2656.195, 54.855),
    v3(-1608.398, 5262.396, 3.966),
    v3(-937.037, -1044.216, 0.436),
    v3(-2200.313, 4237.116, 48.046),
    v3(-1263.321, -367.5901, 44.5355),
    v3(1018.407, 2457.103, 44.758),
    v3(-3091.239, 660.393, 1.701),
    v3(-193.708, 793.051, 197.758),
    v3(987.808, -105.7523, 74.1212),
    v3(-927.8402, -2934.034, 14.1399),
    v3(-1640.297, -3165.138, 40.8515),
    v3(-1011.272, -1491.967, 4.7604),
    v3(343.7568, 946.6004, 204.4755),
    v3(750.829, 196.948, 85.651),
    v3(-331.626, 6285.987, 34.8),
    v3(-311.981, -1626.432, 31.473),
    v3(819.625, -796.649, 35.338),
    v3(132.977, -576.783, 18.278),
    v3(-1442.642, 567.622, 121.601),
    v3(-363.567, 572.64, 127.044),
    v3(-763.812, 705.641, 144.732),
    v3(1902.373, 572.778, 176.627),
    v3(-672.715, 59.853, 61.902),
    v3(43.7134, 2791.532, 57.6598),
    v3(1220.985, 1902.975, 78.0406),
    v3(2517.942, 2615.929, 38.086),
    v3(3455.177, 5510.634, 18.769),
    v3(1500.862, -2513.839, 56.26),
    v3(1467.102, 1096.74, 113.988),
    v3(545.206, 2880.917, 42.441),
    v3(2612.129, 2782.483, 34.102),
    v3(-14.178, 6491.451, 37.251),
    v3(-788.846, -2086.048, 9.164),
    v3(981.079, -2583.384, 10.37),
    v3(964.371, -1811.011, 31.146),
    v3(511.737, -1335.028, 29.488),
    v3(-69.0361, -1229.77, 29.3137),
    v3(202.812, -1758.72, 33.229),
    v3(-328.378, -1372.415, 41.193),
    v3(-1635.991, -1031.127, 13.024),
    v3(955.454, 73.628, 112.592),
    v3(265.722, -1335.354, 36.17),
    v3(-1033.097, -825.029, 19.049),
    v3(-592.9804, -875.5658, 25.5693),
    v3(-246.484, -786.507, 30.531),
    v3(479.364, -574.451, 28.5),
    v3(1098.204, -1528.952, 34.475),
    v3(580.785, -2284.23, 6.491),
    v3(-295.973, -308.098, 9.511),
    v3(-117.05, -1025.36, 27.318),
}
local street_dealers = {
    v3(550.8953, -1774.517, 28.3121),
    v3(-154.924, 6434.428, 30.916),
    v3(400.9768, 2635.369, 43.5045),
    v3(1533.846, 3796.837, 33.456),
    v3(-1666.642, -1080.02, 12.1537),
    v3(-1560.61, -413.3221, 37.1001),
    v3(819.2939, -2988.856, 5.0209),
    v3(1001.701, -2162.448, 29.567),
    v3(1388.968, -1506.082, 57.0407),
    v3(-3054.574, 556.711, 0.661),
    v3(-72.8903, 80.717, 70.6161),
    v3(198.6676, -167.0663, 55.3187),
    v3(814.636, -280.109, 65.463),
    v3(-237.004, -256.513, 38.122),
    v3(-493.654, -720.734, 22.921),
    v3(156.1586, 6656.525, 30.5882),
    v3(1986.313, 3786.75, 31.2791),
    v3(-685.5629, 5762.871, 16.511),
    v3(1707.703, 4924.311, 41.078),
    v3(1195.305, 2630.469, 36.81),
    v3(167.0163, 2228.922, 89.7867),
    v3(2724.008, 1483.066, 23.5007),
    v3(1594.933, 6452.817, 24.3172),
    v3(-2177.397, 4275.945, 48.12),
    v3(-2521.249, 2311.794, 32.216),
    v3(-3162.873, 1115.642, 19.8526),
    v3(-1145.026, -2048.466, 12.218),
    v3(-1304.321, -1318.848, 3.88),
    v3(-946.727, 322.081, 70.357),
    v3(-895.112, -776.624, 14.91),
    v3(-250.614, -1527.617, 30.561),
    v3(-601.639, -1026.49, 21.55),
    v3(2712.987, 4324.116, 44.8521),
    v3(726.772, 4169.101, 39.709),
    v3(178.3272, 3086.26, 42.0742),
    v3(2351.592, 2524.249, 46.694),
    v3(388.9941, 799.6882, 186.6764),
    v3(2587.982, 433.6803, 107.6139),
    v3(830.2875, -1052.775, 27.6666),
    v3(-759.662, -208.396, 36.271),
    v3(-43.7171, -2015.22, 17.017),
    v3(124.02, -1039.884, 28.213),
    v3(479.0473, -597.5507, 27.4996),
    v3(959.67, 3619.036, 31.668),
    v3(2375.899, 3162.995, 47.2087),
    v3(-1505.687, 1526.558, 114.257),
    v3(645.737, 242.173, 101.153),
    v3(1173.138, -388.2896, 70.5896),
    v3(-1801.85, 172.49, 67.771),
    v3(3729.257, 4524.872, 21.4755),
}
local snowmen = {
    v3(-374.0548, 6230.472, 30.4462),
    v3(1558.484, 6449.396, 22.8348),
    v3(3314.504, 5165.038, 17.386),
    v3(1709.097, 4680.172, 41.919),
    v3(-1414.734, 5101.661, 59.248),
    v3(1988.997, 3830.344, 31.376),
    v3(234.725, 3103.582, 41.434),
    v3(2357.556, 2526.069, 45.5),
    v3(1515.591, 1721.268, 109.26),
    v3(-45.725, 1963.218, 188.93),
    v3(-1517.221, 2140.711, 54.936),
    v3(-2830.558, 1420.358, 99.885),
    v3(-2974.729, 713.9555, 27.3101),
    v3(-1938.257, 589.845, 118.757),
    v3(-456.1271, 1126.606, 324.7816),
    v3(-820.763, 165.984, 70.254),
    v3(218.7153, -104.1239, 68.7078),
    v3(902.2285, -285.8174, 64.6523),
    v3(-777.0854, 880.5856, 202.3774),
    v3(1270.095, -645.7452, 66.9289),
    v3(180.9037, -904.4719, 29.6439),
    v3(-958.819, -780.149, 16.819),
    v3(-1105.382, -1398.65, 4.1505),
    v3(-252.2187, -1561.523, 30.8514),
    v3(1340.639, -1585.771, 53.218),
}
local blaine_county_clues = {
    v3(1111.145, 3144.103, 36.1949),
    v3(-133.8088, 1912.384, 195.3329),
    v3(-679.3479, 5800.79, 15.337),
    v3(1904.175, 4912.89, 46.88321),
}
local blaine_county_final = {
    v3(2898.955, 3654.93, 42.84441),
    v3(2568.3, 1263.647, 42.62333),
    v3(-1568.47, 4423.41, 5.116028),
    v3(-1709.996, 2619.301, 1.110783),
    v3(2437.768, 5835.223, 56.75886),
}
local explr_mode = true
local my_root = menu.my_root()
menu.toggle(my_root, "Explore Mode", {}, 'Essentially a "Spoiler-Free" mode.\nRather than show all collectibles on the map, this will only show very close ones, and flash your map when one is nearby.', function(st) explr_mode = st end, explr_mode)
local dbg = false
local function has_jammer(jam_id)
    local stat_id = 28099 + jam_id
    return STATS.GET_PACKED_STAT_BOOL_CODE(stat_id, -1)
end
local function has_action_figure(fig_id)
    if fig_id >= 98 then
        for i=0,97 do
            if not STATS.GET_PACKED_STAT_BOOL_CODE(26811 + i, -1) then
                return true
            end
        end
    end
    return STATS.GET_PACKED_STAT_BOOL_CODE(26811 + fig_id, -1)
end
local function is_mp()
    return util.is_session_started()
end
local function is_sp()
    return not util.is_session_started()
end
local function has_peyote(peyote_id)
    return false
end
local function has_playing_card(card_id)
    return STATS.GET_PACKED_STAT_BOOL_CODE(26911 + card_id, -1)
end
local function has_movie_prop(movie_prop_id)
    local stat_id = 30230 + movie_prop_id
    return STATS.GET_PACKED_STAT_BOOL_CODE(stat_id, -1)
end
local function can_lantern()
    if tunable_collectables_trick_or_treat and is_mp() then
        return readTunableBool(tunable_collectables_trick_or_treat)
    end
end
local function has_lantern(lntrn_id)
    local stat = 34252 + lntrn_id
    if lntrn_id > 9 then
        stat += 250
    end
    return STATS.GET_PACKED_STAT_BOOL_CODE(stat, -1)
end
local function can_ld_product()
    if tunable_collectables_ld_organics and is_mp() then
        return readTunableBool(tunable_collectables_ld_organics)
    end
end

local function can_letterscrap()
    return SCRIPT.GET_NUMBER_OF_THREADS_RUNNING_THE_SCRIPT_WITH_THIS_HASH(util.joaat("letterScraps")) ~= 0
end
local function has_letterscrap(scrap_id)
    return memory.read_int(memory.script_global(113810+10052+122 + (scrap_id) // 32)) & (1 << (scrap_id % 32)) ~= 0
end
local function can_spaceshippart()
    return SCRIPT.GET_NUMBER_OF_THREADS_RUNNING_THE_SCRIPT_WITH_THIS_HASH(util.joaat("spaceshipParts")) ~= 0
end
local function has_spaceshippart(part_id)
    return memory.read_int(memory.script_global(113810+10052+125 + (part_id) // 32)) & (1 << (part_id % 32)) ~= 0
end
local function has_ld_product(prod_id)
    return STATS.GET_PACKED_STAT_BOOL_CODE(34262 + prod_id, -1)
end
local function can_peyote()
    if tunable_vc_peyote_enable and is_mp() then
        return readTunableBool(tunable_vc_peyote_enable)
    end
end
local function can_snowmen()
    if tunable_collectables_snowmen and is_mp() then
        return readTunableBool(tunable_collectables_snowmen)
    end
end
local function has_snowman(snowman_id)
    return STATS.GET_PACKED_STAT_BOOL_CODE(36630 + snowman_id, -1)
end
local function is_peyote_available(idx)
    switch (idx) do
        case 0:
		case 1:
		case 2:
		case 3:
		case 4:
			return not readTunableBool(tunables_vc_peyote_disable_1)
		
		case 5:
		case 6:
		case 7:
		case 8:
		case 9:
			return not readTunableBool(tunables_vc_peyote_disable_2)
		
		case 10:
		case 11:
		case 12:
		case 13:
		case 14:
			return not readTunableBool(tunables_vc_peyote_disable_3)
		
		case 15:
		case 16:
		case 17:
		case 18:
		case 19:
			return not readTunableBool(tunables_vc_peyote_disable_4)
		
		case 20:
		case 21:
		case 22:
		case 23:
		case 24:
			return not readTunableBool(tunables_vc_peyote_disable_5)
		
		case 25:
		case 26:
		case 27:
		case 28:
		case 29:
			return not readTunableBool(tunables_vc_peyote_disable_6)

		case 30:
		case 31:
		case 32:
		case 33:
		case 34:
			return not readTunableBool(tunables_vc_peyote_disable_7)
		
		case 35:
		case 36:
		case 37:
		case 38:
		case 39:
			return not readTunableBool(tunables_vc_peyote_disable_8)
		
		case 40:
		case 41:
		case 42:
		case 43:
		case 44:
			return not readTunableBool(tunables_vc_peyote_disable_9)

		case 45:
		case 46:
		case 47:
		case 48:
		case 49:
			return not readTunableBool(tunables_vc_peyote_disable_10)
		
		case 50:
		case 51:
		case 52:
		case 53:
		case 54:
			return not readTunableBool(tunables_vc_peyote_disable_11)
		
		case 55:
		case 56:
		case 57:
		case 58:
		case 59:
			return not readTunableBool(tunables_vc_peyote_disable_12)
			break;
		
		case 60:
		case 61:
		case 62:
		case 63:
		case 64:
			return not readTunableBool(tunables_vc_peyote_disable_13)
			break;
		
		case 65:
		case 66:
		case 67:
		case 68:
		case 69:
			return not readTunableBool(tunables_vc_peyote_disable_14)
		
		case 70:
		case 71:
		case 72:
		case 73:
		case 76:
			return not readTunableBool(tunables_vc_peyote_disable_15)
		
		case 74:
			return not readTunableBool(tunables_vc_peyote_disable_15) and not readTunableBool(tunables_vc_peyote_disable_sasquatch_loc)
		
		case 75:
			return not readTunableBool(tunables_vc_peyote_disable_15) and not readTunableBool(tunables_vc_peyote_disable_chop_loc)
    end
end
local function get_blaine_county_progress()
    local stat_id = 28149
    for i=1,5 do
        if not STATS.GET_PACKED_STAT_BOOL_CODE(stat_id+i, -1) then
            return i
        end
    end
    return 6
end
-- local function get_street_dealer_pos()
--     return street_dealers[memory.read_int(memory.script_global(2793044+6750+31))+1]
-- end

local addNormalCollectible
do
    local blip_pool = {}
    function addNormalCollectible(parent, blip_sprite, blip_name, name_for_config, positions, min_id, has_fn, can_col_fn, coll_exist_fn, explore_dist, clr, scale = 1)
        local pool_id = #blip_pool+1
        local coll_info = {{},  blip_sprite, blip_name, positions, min_id, #positions - 1 + min_id, has_fn, can_col_fn, coll_exist_fn, explore_dist^2, clr, scale, nil, false}
        local mnu = menu.toggle(parent, util.get_label_text(blip_name), {}, "", function(st) coll_info[14] = not st end, true)
        mnu.name_for_config = name_for_config
        coll_info[13] = mnu
        blip_pool[pool_id] = coll_info
        return pool_id
    end
    util.on_stop(function()
        for k, coll_info in blip_pool do
            for _, blip in coll_info[1] do
                remove_blip(blip)
            end
        end
    end)
    util.create_tick_handler(function()
        -- if util.is_session_started() then
            local my_pos = ENTITY.GET_ENTITY_COORDS(players.user_ped())
            for _, coll_info in blip_pool do
                local [blips, blip_sprite, blip_name, positions, min_id, max_id, has_fn, can_col_fn, coll_exist_fn, explore_dist, clr, scale, tgl, disabled] = coll_info
                local ctr = 0
                local max_ctr = 0
                local pos_offs = 1 - min_id
                for i=min_id, max_id do
                    local idx = i+pos_offs
                    local pos = positions[idx]
                    if coll_exist_fn and not coll_exist_fn(i) then
                        continue
                    end
                    max_ctr += 1
                    local has_coll = has_fn(i)
                    if has_coll then
                        ctr += 1
                    end
                    if disabled or (can_col_fn and not can_col_fn()) or (has_coll or (explr_mode and ((my_pos.x - pos.x)^2 + (my_pos.y - pos.y)^2) > explore_dist)) then
                        if (blip := blips[idx]) and HUD.DOES_BLIP_EXIST(blip) then
                            remove_blip(blip)
                        end
                        blips[idx] = nil
                        continue
                    end
                    local blip = blips[idx]
                    if blip == nil or not HUD.DOES_BLIP_EXIST(blip) then
                        blip = add_blip_for_coord(v3.get(pos))
                        blips[idx] = blip
                        if explr_mode then
                            HUD.FLASH_MINIMAP_DISPLAY()
                            HUD.SET_BLIP_FLASH_TIMER(blip, 2000)
                        end
                        HUD.SET_BLIP_SPRITE(blip, blip_sprite)
                        HUD.SET_BLIP_COLOUR(blip, clr or 2)
                        HUD.SET_BLIP_SCALE(blip, scale)
                        HUD.SET_BLIP_NAME_FROM_TEXT_FILE(blip, blip_name)
                        HUD.SET_BLIP_AS_SHORT_RANGE(blip, true)
                        HUD.SHOW_HEIGHT_ON_BLIP(blip, true)
                    end
                end
                menu.set_help_text(tgl, "%i / %i":format(ctr, max_ctr))
            end
        -- else
        --     for k, coll_info in blip_pool do
        --         for _, blip in coll_info[1] do
        --             remove_blip(blip)
        --         end
        --     end
        -- end
    end)
end
local DIST_NOR = 120
local DIST_HIGH = 180
local sp_list = my_root:list("SP Collectibles")
addNormalCollectible(sp_list, 525, "NUM_HIDDEN_PACKAGES_0", "Letter Scraps", letterscraps, 0, has_letterscrap, can_letterscrap, nil, 140, 12, 0.75)
addNormalCollectible(sp_list, 752, "NUM_HIDDEN_PACKAGES_1", "Spaceship Parts", spaceshipparts, 0, has_spaceshippart, can_spaceshippart, nil, 140, 30, 0.8)
local mp_list = my_root:list("MP Collectibles")
addNormalCollectible(mp_list, 671, "PIM_ACTIONFIG", "Action Figures", figures, 0, has_action_figure, is_mp, nil, 140, 30)
addNormalCollectible(mp_list, 769, "PIM_SIGNAL", "Signal Jammers", jammers, 0, has_jammer, is_mp, nil, 190, 1)
addNormalCollectible(mp_list, 680, "PIM_PLAYINGCAR", "Playing Cards", cards, 0, has_playing_card, is_mp, nil, 140, 27)
addNormalCollectible(mp_list, 790, "PIM_FILM_COL", "Movie Props", movie_prop, 0, has_movie_prop, is_mp, nil, 140, 6)
addNormalCollectible(mp_list, 781, "PIM_TRICKTR", "Trick Or Treat", lanterns, 0, has_lantern, can_lantern, nil, 140, 64)
addNormalCollectible(mp_list, 140, "PIM_ORGANITR", "LD Organics Product", ld_product, 0, has_ld_product, can_ld_product, nil, 140, 2)
addNormalCollectible(mp_list, 141, "PIM_SNOWMENTR", "Snowmen", snowmen, 0, has_snowman, can_snowmen, nil, 140, 3)
addNormalCollectible(mp_list, 141, "NUM_HIDDEN_PACKAGES_5", "Peyote Plants", peyotes, 0, has_peyote, can_peyote, nil, 140, 33)

local bln_enable = true
local slasher_btn = mp_list:toggle(util.get_label_text("SERIALKILLBLIP"), {}, "", function(st)
    bln_enable = st
end, true)
slasher_btn.name_for_config = "Los Santos Slasher"
local blaine_county_blip
util.create_tick_handler(function()
    local blaine_county_progress = get_blaine_county_progress()
    slasher_btn.help_text = "%i / %i":format(blaine_county_progress, 6)
    if bln_enable and util.is_session_started() and blaine_county_progress ~= 6 then
        if blaine_county_blip == nil then
            blaine_county_blip = add_blip_for_coord(0,0,0)
            HUD.SET_BLIP_SPRITE(blaine_county_blip,484)
            HUD.SET_BLIP_COLOUR(blaine_county_blip, 76)
            HUD.SET_BLIP_NAME_FROM_TEXT_FILE(blaine_county_blip,"SERIALKILLBLIP")
        end
        if blaine_county_progress == 5 then
            local loc = memory.script_local("freemode", 17859+4)
            if loc ~= 0 then
                local finale_pos = memory.read_int(loc)
                HUD.SET_BLIP_COORDS(blaine_county_blip, v3.get(blaine_county_final[finale_pos+1]))
            end
        else
            HUD.SET_BLIP_COORDS(blaine_county_blip, v3.get(blaine_county_clues[blaine_county_progress]))
        end
    elseif blaine_county_blip then
        remove_blip(blaine_county_blip)
        blaine_county_blip = nil
    end
end)

local ghosthunt_enable = true
local ghosthunt_btn = mp_list:toggle("Ghost Hunt", {}, "", function(st)
    ghosthunt_enable = st
end, true)
local ghosthunt_blip
util.create_tick_handler(function()
    local is_ghost_available = false
    local ghostbit_ptr = memory.script_local("fm_content_ghosthunt", 1399+1)
    local ghostpos
    if ghostbit_ptr ~= 0 then
        local ghostbit = memory.read_int(ghostbit_ptr)
        is_ghost_available = (ghostbit & (1 << 14 | 1 << 15 | 1 << 16)) == 0
        local ghostpos_ptr = memory.script_local("fm_content_ghosthunt", 228 + 85 + 1 + 1 + 0*12 + 4)
        ghostpos = v3(ghostpos_ptr)
    end
    if ghosthunt_enable and is_ghost_available and util.is_session_started() then
        if ghosthunt_blip == nil then
            ghosthunt_blip = add_blip_for_coord(0,0,0)
            HUD.SET_BLIP_SPRITE(ghosthunt_blip, 484)
            HUD.SET_BLIP_COLOUR(ghosthunt_blip, 52)
            HUD.SET_BLIP_SCALE(ghosthunt_blip, 1.5)
            -- HUD.SET_BLIP_NAME_FROM_TEXT_FILE(ghosthunt_blip,"SERIALKILLBLIP")
            HUD.BEGIN_TEXT_COMMAND_SET_BLIP_NAME("STRING")
            HUD.ADD_TEXT_COMPONENT_SUBSTRING_PLAYER_NAME("Ghost Hunt")
            HUD.END_TEXT_COMMAND_SET_BLIP_NAME(ghosthunt_blip)
        end
        HUD.SET_BLIP_COORDS(ghosthunt_blip, ghostpos)
    elseif ghosthunt_blip then
        remove_blip(ghosthunt_blip)
        ghosthunt_blip = nil
    end
end)
util.on_stop(function()
    if blaine_county_blip then
        remove_blip(blaine_county_blip)
    end
    if ghosthunt_blip then
        remove_blip(ghosthunt_blip)
    end
end)