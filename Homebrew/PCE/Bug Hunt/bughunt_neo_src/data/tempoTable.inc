;-----------------------------------------------------------------------------------------
;
; TEMPO DATA
;
; starting with value $23 (as sent to PSG_TEMPO),
; these numbers are the timer values to use for
; that tempo
;
psgTempoTable
	.db	$7d		; tempo  35 : 125 =>  55.936 Hz : 35 bpm = .583 bps
	.db	$79		; tempo  36 : 121 =>  57.785 Hz : 36 bpm = .600 bps
	.db	$76		; tempo  37 : 118 =>  59.254 Hz
	.db	$73		; tempo  38 : 115 =>  60.800 Hz
	.db	$70		; tempo  39 : 112 =>  62.429 Hz
	.db	$6d		; tempo  40 : 109 =>  64.147 Hz
	.db	$6b		; tempo  41 : 107 =>  65.346 Hz
	.db	$68		; tempo  42 : 104 =>  67.231 Hz
	.db	$65		; tempo  43 : 101 =>  69.228 Hz
	.db	$63		; tempo  44 :  99 =>  70.626 Hz
	.db	$61		; tempo  45 :  97 =>  72.082 Hz 
	.db	$5f		; tempo  46 :  95 =>  73.600 Hz
	.db	$5d		; tempo  47 :  93 =>  75.183 Hz
	.db	$5b		; tempo  48 :  91 =>  76.835 Hz
	.db	$59		; tempo  49 :  89 =>  78.562 Hz
	.db	$57		; tempo  50 :  87 =>  80.368 Hz
	.db	$56		; tempo  51 :  86 =>  81.302 Hz
	.db	$54		; tempo  52 :  84 =>  82.238 Hz
	.db	$52		; tempo  53 :  82 =>  85.269 Hz
	.db	$51		; tempo  54 :  81 =>  86.321 Hz
	.db	$4f		; tempo  55 :  79 =>  88.506 Hz
	.db	$4e		; tempo  56 :  78 =>  89.641 Hz
	.db	$4d		; tempo  57 :  77 =>  90.805 Hz
	.db	$4b		; tempo  58 :  75 =>  93.227 Hz
	.db	$4a		; tempo  60 :  74 =>  94.486 Hz
	.db	$49		; tempo  61 :  73 =>  95.781 Hz
	.db	$48		; tempo  62 :  72 =>  97.111 Hz
	.db	$46		; tempo  63 :  70 =>  99.886 Hz
	.db	$45		; tempo  64 :  69 => 101.333 Hz 
	.db	$44		; tempo  65 :  68 => 102.824 Hz
	.db	$43		; tempo  66 :  67 => 104.258 Hz
	.db	$42		; tempo  67 :  66 => 105.940 Hz
	.db	$41		; tempo  68 :  65 => 107.570 Hz
	.db	$40		; tempo  69 :  64 => 109.250 Hz
	.db	$3f		; tempo  70 :  63 => 110.984 Hz
	.db	$3e		; tempo  71 :  62 => 112.774 Hz
	.db	$3e		; tempo  72 :  
	.db	$3d		; tempo  73 :  61 => 114.623 Hz
	.db	$3c		; tempo  74 :  60 => 116.533 Hz
	.db	$3b		; tempo  75 :  59 => 118.508 Hz
	.db	$3a		; tempo  76 :  58 => 120.552 Hz 
	.db	$3a		; tempo  77 :  
	.db	$39		; tempo  78 :  57 => 122.667 Hz
	.db	$38		; tempo  79 :  56 => 124.857 Hz
	.db	$37		; tempo  80 :  55 => 127.127 Hz
	.db	$37		; tempo  81 : 
	.db	$36		; tempo  82 :  54 => 129.482 Hz
	.db	$35		; tempo  83 :  53 => 131.925 Hz
	.db	$35		; tempo  84 : 
	.db	$34		; tempo  85 :  52 => 134.462 Hz
	.db	$33		; tempo  86 :  51 => 137.098 Hz
	.db	$33		; tempo  87 : 
	.db	$32		; tempo  88 :  50 => 218.500 Hz
	.db	$32		; tempo  89 : 
	.db	$31		; tempo  90 :  49 => 142.694 Hz
	.db	$31		; tempo  91 : 
	.db	$30		; tempo  92 :  48 => 145.667 Hz
	.db	$30		; tempo  93 : 
	.db	$2f		; tempo  94 :  47 => 148.766 Hz
	.db	$2f		; tempo  95 : 
	.db	$2e		; tempo  96 :  46 => 152.000 Hz
	.db	$2e		; tempo  97 : 
	.db	$2d		; tempo  98 :  45 => 155.378 Hz
	.db	$2d		; tempo  99 : 
	.db	$2c		; tempo 100 :  44 => 158.909 Hz
	.db	$2c		; tempo 101 : 
	.db	$2b		; tempo 102 :  43 => 162.605 Hz
	.db	$2b		; tempo 103 : 
	.db	$2a		; tempo 104 :  42 => 166.476 Hz
	.db	$2a		; tempo 105 : 
	.db	$2a		; tempo 106 : 
	.db	$29		; tempo 107 :  41 => 170.537 Hz
	.db	$29		; tempo 108 : 
	.db	$28		; tempo 109 :  40 => 174.800 Hz
	.db	$28		; tempo 110 : 
	.db	$28		; tempo 111 : 
	.db	$27		; tempo 112 :  39 => 179.282 Hz
	.db	$27		; tempo 113 : 
	.db	$27		; tempo 114 : 
	.db	$26		; tempo 115 :  38 => 184.000 Hz
	.db	$26		; tempo 116 : 
	.db	$26		; tempo 117 : 
	.db	$25		; tempo 118 :  37 => 188.973 Hz
	.db	$25		; tempo 119 : 
	.db	$25		; tempo 120 : 
	.db	$24		; tempo 121 :  36 => 194.222 Hz
	.db	$24		; tempo 122 : 
	.db	$24		; tempo 123 : 
	.db	$24		; tempo 124 : 
	.db	$23		; tempo 125 :  35 => 199.771 Hz
	.db	$23		; tempo 126 : 
	.db	$23		; tempo 127 : 
	.db	$22		; tempo 128 :  34 => 205.647 Hz
	.db	$22		; tempo 129 : 
	.db	$22		; tempo 130 : 
	.db	$22		; tempo 131 : 
	.db	$22		; tempo 132 : 
	.db	$21		; tempo 133 :  33 => 211.879 Hz
	.db	$21		; tempo 134 : 
	.db	$21		; tempo 135 :  32 => 218.500 Hz
	.db	$20		; tempo 136 : 
	.db	$20		; tempo 137 : 
	.db	$20		; tempo 138 : 
	.db	$20		; tempo 139 : 
	.db	$1f		; tempo 140 :  31 => 225.548 Hz
	.db	$1f		; tempo 141 : 
	.db	$1f		; tempo 142 : 
	.db	$1f		; tempo 143 : 
	.db	$1f		; tempo 144 : 
	.db	$1e		; tempo 145 :  30 => 233.067 Hz
	.db	$1e		; tempo 146 : 
	.db	$1e		; tempo 147 : 
	.db	$1e		; tempo 148 : 
	.db	$1e		; tempo 149 : 
	.db	$1d		; tempo 150 :  29 => 241.103 Hz
	.db	$1d		; tempo 151 : 
	.db	$1d		; tempo 152 : 
	.db	$1d		; tempo 153 : 
	.db	$1d		; tempo 154 : 
	.db	$1c		; tempo 155 :  28 => 249.714 Hz
	.db	$1c		; tempo 156 : 
	.db	$1c		; tempo 157 : 
	.db	$1c		; tempo 158 : 
	.db	$1c		; tempo 159 : 
	.db	$1b		; tempo 160 :  27 => 258.963 Hz
	.db	$1b		; tempo 161 : 
	.db	$1b		; tempo 162 : 
	.db	$1b		; tempo 163 : 
	.db	$1b		; tempo 164 : 
	.db	$1b		; tempo 165 : 
	.db	$1a		; tempo 166 :  26 => 268.923 Hz
	.db	$1a		; tempo 167 : 
	.db	$1a		; tempo 168 : 
	.db	$1a		; tempo 169 : 
	.db	$1a		; tempo 170 : 
	.db	$1a		; tempo 171 : 
	.db	$1a		; tempo 172 : 
	.db	$19		; tempo 173 :  25 => 279.68 Hz
	.db	$19		; tempo 174 : 
	.db	$19		; tempo 175 : 
	.db	$19		; tempo 176 : 
	.db	$19		; tempo 177 : 
	.db	$19		; tempo 178 : 
	.db	$19		; tempo 179 : 
	.db	$18		; tempo 180 :  24 => 291.333 Hz
	.db	$18		; tempo 181 : 
	.db	$18		; tempo 182 : 
	.db	$18		; tempo 183 : 
	.db	$18		; tempo 184 : 
	.db	$18		; tempo 185 : 
	.db	$18		; tempo 186 : 
	.db	$17		; tempo 187 :  23 => 304.000 Hz
	.db	$17		; tempo 188 : 
	.db	$17		; tempo 189 : 
	.db	$17		; tempo 190 : 
	.db	$17		; tempo 191 : 
	.db	$17		; tempo 192 : 
	.db	$17		; tempo 193 : 
	.db	$17		; tempo 194 : 
	.db	$17		; tempo 195 : 
	.db	$16		; tempo 196 :  22 => 317.818 Hz
	.db	$16		; tempo 197 : 
	.db	$16		; tempo 198 : 
	.db	$16		; tempo 199 : 
	.db	$16		; tempo 200 : 
	.db	$16		; tempo 201 : 
	.db	$16		; tempo 202 : 
	.db	$16		; tempo 203 : 
	.db	$16		; tempo 204 : 
	.db	$15		; tempo 205 :  21 => 332.952 Hz
	.db	$15		; tempo 206 : 
	.db	$15		; tempo 207 : 
	.db	$15		; tempo 208 : 
	.db	$15		; tempo 209 : 
	.db	$15		; tempo 210 : 
	.db	$15		; tempo 211 : 
	.db	$15		; tempo 212 : 
	.db	$15		; tempo 213 : 
	.db	$15		; tempo 214 : 
	.db	$14		; tempo 215 :  20 => 349.600Hz
;	.db	$14		; tempo 216 : 
;	.db	$14		; tempo 217 : 
;	.db	$14		; tempo 218 : 
;	.db	$14		; tempo 219 : 
;	.db	$14		; tempo 220 : -->> end of actual tempos
;	.db	$14		; tempo 221 : 
;	.db	$14		; tempo 222 : 
;	.db	$14		; tempo 223 : 
;	.db	$14		; tempo 224 : 
;	.db	$14		; tempo 225 : 
;	.db	$13		; tempo 226 :  19 => 368.000 Hz
;	.db	$13		; tempo 227 : 
;	.db	$13		; tempo 228 : 
;	.db	$13		; tempo 229 : 
;	.db	$13		; tempo 230 : 
;	.db	$13		; tempo 231 : 
;	.db	$13		; tempo 232 : 
;	.db	$13		; tempo 233 : 
;	.db	$13		; tempo 234 : 
;	.db	$13		; tempo 235 : 
;	.db	$13		; tempo 236 : 
;	.db	$13		; tempo 237 : 
;	.db	$12		; tempo 238 :  18 => 388.444 Hz
;	.db	$12		; tempo 239 : 
;	.db	$12		; tempo 240 : 
;	.db	$12		; tempo 241 : 
;	.db	$12		; tempo 242 : 
;	.db	$12		; tempo 243 : 
;	.db	$12		; tempo 244 : 
;	.db	$12		; tempo 245 : 
;	.db	$12		; tempo 246 : 
;	.db	$12		; tempo 247 : 
;	.db	$12		; tempo 248 : 
;	.db	$12		; tempo 249 : 
;	.db	$12		; tempo 250 : 
;	.db	$11		; tempo 251 :  17 => 411.294 Hz
;	.db	$11		; tempo 252 : 
;	.db	$11		; tempo 253 : 
;	.db	$11		; tempo 254 : 
;	.db	$11		; tempo 255 : 
;	.db	$11		; tempo 256 :


