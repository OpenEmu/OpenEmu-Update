const unsigned char sprSecretaryWalk1R[]={
0,0,0x00,0,
8,0,0x01,0,
0,8,0x09,1,
8,8,0x0a,1,
0,16,0x18,1,
8,16,0x19,1,
128
};

const unsigned char sprSecretaryWalk2R[]={
0,0,0x02,0,
8,0,0x03,0,
0,8,0x0b,1,
8,8,0x0c,1,
0,16,0x1a,1,
8,16,0x1b,1,
128
};

const unsigned char sprSecretaryWalk3R[]={
0,0,0x00,0,
8,0,0x01,0,
0,8,0x0d,1,
8,8,0x0e,1,
0,16,0x1c,1,
8,16,0x1d,1,
128
};

const unsigned char sprSecretaryWalk4R[]={
0,0,0x02,0,
8,0,0x03,0,
0,8,0x0b,1,
8,8,0x0f,1,
0,16,0x1e,1,
8,16,0x1f,1,
128
};

const unsigned char sprSecretaryWalk1L[]={
0,0,0x01,0|OAM_FLIP_H,
8,0,0x00,0|OAM_FLIP_H,
0,8,0x0a,1|OAM_FLIP_H,
8,8,0x09,1|OAM_FLIP_H,
0,16,0x19,1|OAM_FLIP_H,
8,16,0x18,1|OAM_FLIP_H,
128
};

const unsigned char sprSecretaryWalk2L[]={
0,0,0x03,0|OAM_FLIP_H,
8,0,0x02,0|OAM_FLIP_H,
0,8,0x0c,1|OAM_FLIP_H,
8,8,0x0b,1|OAM_FLIP_H,
0,16,0x1b,1|OAM_FLIP_H,
8,16,0x1a,1|OAM_FLIP_H,
128
};

const unsigned char sprSecretaryWalk3L[]={
0,0,0x01,0|OAM_FLIP_H,
8,0,0x00,0|OAM_FLIP_H,
0,8,0x0e,1|OAM_FLIP_H,
8,8,0x0d,1|OAM_FLIP_H,
0,16,0x1d,1|OAM_FLIP_H,
8,16,0x1c,1|OAM_FLIP_H,
128
};

const unsigned char sprSecretaryWalk4L[]={
0,0,0x03,0|OAM_FLIP_H,
8,0,0x02,0|OAM_FLIP_H,
0,8,0x0f,1|OAM_FLIP_H,
8,8,0x0b,1|OAM_FLIP_H,
0,16,0x1f,1|OAM_FLIP_H,
8,16,0x1e,1|OAM_FLIP_H,
128
};

const unsigned char sprSecretaryAnswer1R[]={
0,0,0x00,0,
8,0,0x3e,0,
0,8,0x09,1,
8,8,0xfe,1,
0,16,0x18,1,
8,16,0x19,1,
128
};

const unsigned char sprSecretaryAnswer2R[]={
0,0,0x02,0,
8,0,0x08,0,
0,8,0x0b,1,
8,8,0xfb,1,
0,16,0x1a,1,
8,16,0x1b,1,
128
};

const unsigned char sprSecretaryAnswer3R[]={
0,0,0x00,0,
8,0,0x3e,0,
0,8,0x0d,1,
8,8,0xfe,1,
0,16,0x1c,1,
8,16,0x1d,1,
128
};

const unsigned char sprSecretaryAnswer4R[]={
0,0,0x02,0,
8,0,0x08,0,
0,8,0x0b,1,
8,8,0xf9,1,
0,16,0x1e,1,
8,16,0x1f,1,
128
};

const unsigned char sprSecretaryAnswer1L[]={
0,0,0x3e,0|OAM_FLIP_H,
8,0,0x00,0|OAM_FLIP_H,
0,8,0xfe,1|OAM_FLIP_H,
8,8,0x09,1|OAM_FLIP_H,
0,16,0x19,1|OAM_FLIP_H,
8,16,0x18,1|OAM_FLIP_H,
128
};

const unsigned char sprSecretaryAnswer2L[]={
0,0,0x08,0|OAM_FLIP_H,
8,0,0x02,0|OAM_FLIP_H,
0,8,0xfb,1|OAM_FLIP_H,
8,8,0x0b,1|OAM_FLIP_H,
0,16,0x1b,1|OAM_FLIP_H,
8,16,0x1a,1|OAM_FLIP_H,
128
};

const unsigned char sprSecretaryAnswer3L[]={
0,0,0x3e,0|OAM_FLIP_H,
8,0,0x00,0|OAM_FLIP_H,
0,8,0xfe,1|OAM_FLIP_H,
8,8,0x0d,1|OAM_FLIP_H,
0,16,0x1d,1|OAM_FLIP_H,
8,16,0x1c,1|OAM_FLIP_H,
128
};

const unsigned char sprSecretaryAnswer4L[]={
0,0,0x08,0|OAM_FLIP_H,
8,0,0x02,0|OAM_FLIP_H,
0,8,0xf9,1|OAM_FLIP_H,
8,8,0x0b,1|OAM_FLIP_H,
0,16,0x1f,1|OAM_FLIP_H,
8,16,0x1e,1|OAM_FLIP_H,
128
};


const unsigned char sprSecretaryWalk1D[]={
0,0,0x04,0,
8,0,0x05,0,
0,8,0x10,1,
8,8,0x11,1,
0,16,0x20,1,
8,16,0x21,1,
128
};

const unsigned char sprSecretaryWalk2D[]={
0,0,0x04,0,
8,0,0x05,0,
0,8,0x12,1,
8,8,0x13,1,
0,16,0x22,1,
8,16,0x23,1,
128
};

const unsigned char sprSecretaryWalk1U[]={
0,0,0x06,0,
8,0,0x07,0,
0,8,0x14,1,
8,8,0x15,1,
0,16,0x20,1,
8,16,0x24,1,
128
};

const unsigned char sprSecretaryWalk2U[]={
0,0,0x06,0,
8,0,0x07,0,
0,8,0x16,1,
8,8,0x17,1,
0,16,0x25,1,
8,16,0x23,1,
128
};

const unsigned char sprSecretaryKnocked1R[]={
0,0,0x00,0,
8,0,0x01,0,
0,8,0x26,1,
8,8,0x27,1,
0,16,0x2a,1,
8,16,0x2b,1,
128
};

const unsigned char sprSecretaryKnocked2R[]={
0,0,0xfa,0,
8,0,0xfa,0,
0,8,0x28,0,
8,8,0x29,0,
0,16,0x2c,1,
8,16,0x2d,1,
128
};

const unsigned char sprSecretaryKnocked1L[]={
0,0,0x01,0|OAM_FLIP_H,
8,0,0x00,0|OAM_FLIP_H,
0,8,0x27,1|OAM_FLIP_H,
8,8,0x26,1|OAM_FLIP_H,
0,16,0x2b,1|OAM_FLIP_H,
8,16,0x2a,1|OAM_FLIP_H,
128
};

const unsigned char sprSecretaryKnocked2L[]={
0,0,0xfa,0,
8,0,0xfa,0,
0,8,0x29,0|OAM_FLIP_H,
8,8,0x28,0|OAM_FLIP_H,
0,16,0x2d,1|OAM_FLIP_H,
8,16,0x2c,1|OAM_FLIP_H,
128
};

const unsigned char sprSecretaryRest1[]={
8,-2,0xe2,2,
16,-2,0xe3,2,

8,2,0xdb,1,
16,2,0xdc,1,

0,0,0xd8,0,
8,0,0xd9,0,
16,0,0xda,0,
0,8,0xdf,0,
8,8,0xe0,0,
16,8,0xe1,0,

128
};

const unsigned char sprSecretaryRest2[]={
8,-2,0xe2,2,
16,-2,0xe3,2,

8,2,0xdb,1,
16,2,0xdc,1,

0,0,0xd8,0,
8,0,0xd9,0,
16,0,0xda,0,
0,8,0xec,0,
8,8,0xe0,0,
16,8,0xe1,0,

128
};

const unsigned char sprSecretaryRest3[]={
8,-12,0xe4,2,
16,-12,0xe5,2,
8,-4,0xe8,2,
16,-4,0xe9,2,

8,2,0xdd,1,
16,2,0xde,1,

0,0,0xd8,0,
8,0,0xd9,0,
16,0,0xda,0,
0,8,0xdf,0,
8,8,0xe0,0,
16,8,0xe1,0,

128
};

const unsigned char sprSecretaryRest4[]={
8,-12,0xe6,2,
16,-12,0xe7,2,
8,-4,0xea,2,
16,-4,0xeb,2,

8,2,0xdd,1,
16,2,0xde,1,

0,0,0xd8,0,
8,0,0xd9,0,
16,0,0xda,0,
0,8,0xdf,0,
8,8,0xe0,0,
16,8,0xe1,0,

128
};



const unsigned char sprChiefGhostR[]={
0,0,0x2e,2|OAM_BEHIND,
8,0,0x2f,2|OAM_BEHIND,
16,0,0x94,2|OAM_BEHIND,
0,8,0x95,2|OAM_BEHIND,
8,8,0x96,2|OAM_BEHIND,
16,8,0x97,2|OAM_BEHIND,
0,16,0x98,2|OAM_BEHIND,
8,16,0xc5,2|OAM_BEHIND,
16,16,0xc6,2|OAM_BEHIND,
128
};

const unsigned char sprChiefGhostL[]={
0,0,0x94,2|OAM_FLIP_H|OAM_BEHIND,
8,0,0x2f,2|OAM_FLIP_H|OAM_BEHIND,
16,0,0x2e,2|OAM_FLIP_H|OAM_BEHIND,
0,8,0x97,2|OAM_FLIP_H|OAM_BEHIND,
8,8,0x96,2|OAM_FLIP_H|OAM_BEHIND,
16,8,0x95,2|OAM_FLIP_H|OAM_BEHIND,
0,16,0xc6,2|OAM_FLIP_H|OAM_BEHIND,
8,16,0xc5,2|OAM_FLIP_H|OAM_BEHIND,
16,16,0x98,2|OAM_FLIP_H|OAM_BEHIND,
128
};

const unsigned char sprChiefGhostBlaR[]={
0,0,0x2e,2|OAM_BEHIND,
8,0,0x2f,2|OAM_BEHIND,
16,0,0x94,2|OAM_BEHIND,
0,8,0x95,2|OAM_BEHIND,
8,8,0x96,2|OAM_BEHIND,
16,8,0x97,2|OAM_BEHIND,
0,16,0x98,2|OAM_BEHIND,
8,16,0xed,2|OAM_BEHIND,
16,16,0xee,2|OAM_BEHIND,
128
};

const unsigned char sprChiefGhostBlaL[]={
0,0,0x94,2|OAM_FLIP_H|OAM_BEHIND,
8,0,0x2f,2|OAM_FLIP_H|OAM_BEHIND,
16,0,0x2e,2|OAM_FLIP_H|OAM_BEHIND,
0,8,0x97,2|OAM_FLIP_H|OAM_BEHIND,
8,8,0x96,2|OAM_FLIP_H|OAM_BEHIND,
16,8,0x95,2|OAM_FLIP_H|OAM_BEHIND,
0,16,0xee,2|OAM_FLIP_H|OAM_BEHIND,
8,16,0xed,2|OAM_FLIP_H|OAM_BEHIND,
16,16,0x98,2|OAM_FLIP_H|OAM_BEHIND,
128
};



const unsigned char sprChiefWalk1R[]={
0,0,0x40,0,
8,0,0x41,0,
0,8,0x47,2,
8,8,0x48,2,
0,16,0x4b,2,
8,16,0x4c,2,
128
};

const unsigned char sprChiefWalk2R[]={
0,0,0x42,0,
8,0,0x43,0,
0,8,0x49,2,
8,8,0x4a,2,
0,16,0x4d,2,
8,16,0x4e,2,
128
};

const unsigned char sprChiefWalk3R[]={
0,0,0x40,0,
8,0,0x41,0,
0,8,0x47,2,
8,8,0x48,2,
0,16,0x4f,2,
8,16,0x50,2,
128
};

const unsigned char sprChiefWalk4R[]={
0,0,0x42,0,
8,0,0x43,0,
0,8,0x49,2,
8,8,0x4a,2,
0,16,0x51,2,
8,16,0x52,2,
128
};

const unsigned char sprChiefWalk1L[]={
0,0,0x41,0|OAM_FLIP_H,
8,0,0x40,0|OAM_FLIP_H,
0,8,0x48,2|OAM_FLIP_H,
8,8,0x47,2|OAM_FLIP_H,
0,16,0x4c,2|OAM_FLIP_H,
8,16,0x4b,2|OAM_FLIP_H,
128
};

const unsigned char sprChiefWalk2L[]={
0,0,0x43,0|OAM_FLIP_H,
8,0,0x42,0|OAM_FLIP_H,
0,8,0x4a,2|OAM_FLIP_H,
8,8,0x49,2|OAM_FLIP_H,
0,16,0x4e,2|OAM_FLIP_H,
8,16,0x4d,2|OAM_FLIP_H,
128
};

const unsigned char sprChiefWalk3L[]={
0,0,0x41,0|OAM_FLIP_H,
8,0,0x40,0|OAM_FLIP_H,
0,8,0x48,2|OAM_FLIP_H,
8,8,0x47,2|OAM_FLIP_H,
0,16,0x50,2|OAM_FLIP_H,
8,16,0x4f,2|OAM_FLIP_H,
128
};

const unsigned char sprChiefWalk4L[]={
0,0,0x43,0|OAM_FLIP_H,
8,0,0x42,0|OAM_FLIP_H,
0,8,0x4a,2|OAM_FLIP_H,
8,8,0x49,2|OAM_FLIP_H,
0,16,0x52,2|OAM_FLIP_H,
8,16,0x51,2|OAM_FLIP_H,
128
};

const unsigned char sprChiefTalk1R[]={
0,0,0x42,0,
8,0,0x43,0,
0,8,0x49,2,
8,8,0x4a,2,
0,16,0x53,2,
8,16,0x54,2,
128
};

const unsigned char sprChiefTalk2R[]={
0,0,0x42,0,
8,0,0x43,0,
0,8,0x49,2,
8,8,0x4a,2,
0,16,0x53,2,
8,16,0x54,2,
128
};

const unsigned char sprChiefTalk3R[]={
0,0,0x44,0,
8,0,0x45,0,
0,8,0x49,2,
8,8,0x4a,2,
0,16,0x53,2,
8,16,0x54,2,
128
};

const unsigned char sprChiefTalk1L[]={
0,0,0x43,0|OAM_FLIP_H,
8,0,0x42,0|OAM_FLIP_H,
0,8,0x4a,2|OAM_FLIP_H,
8,8,0x49,2|OAM_FLIP_H,
0,16,0x54,2|OAM_FLIP_H,
8,16,0x53,2|OAM_FLIP_H,
128
};

const unsigned char sprChiefTalk2L[]={
0,0,0x43,0|OAM_FLIP_H,
8,0,0x42,0|OAM_FLIP_H,
0,8,0x4a,2|OAM_FLIP_H,
8,8,0x49,2|OAM_FLIP_H,
0,16,0x54,2|OAM_FLIP_H,
8,16,0x53,2|OAM_FLIP_H,
128
};

const unsigned char sprChiefTalk3L[]={
0,0,0x45,0|OAM_FLIP_H,
8,0,0x44,0|OAM_FLIP_H,
0,8,0x4a,2|OAM_FLIP_H,
8,8,0x49,2|OAM_FLIP_H,
0,16,0x54,2|OAM_FLIP_H,
8,16,0x53,2|OAM_FLIP_H,
128
};



const unsigned char sprBouncerWalk1R[]={
0,0,0x55,2,
8,0,0x56,2,
0,8,0x5c,2,
8,8,0x5d,2,
0,16,0x62,2,
8,16,0x63,2,
128
};

const unsigned char sprBouncerWalk2R[]={
0,0,0x57,2,
8,0,0x58,2,
0,8,0x5e,2,
8,8,0x5f,2,
0,16,0x64,2,
8,16,0x65,2,
128
};

const unsigned char sprBouncerWalk3R[]={
0,0,0x59,2,
8,0,0x5a,2,
0,8,0x5c,2,
8,8,0x60,2,
0,16,0x66,2,
8,16,0x67,2,
128
};

const unsigned char sprBouncerWalk4R[]={
0,0,0x57,2,
8,0,0x5b,2,
0,8,0x5e,2,
8,8,0x61,2,
0,16,0x68,2,
8,16,0x69,2,
128
};

const unsigned char sprBouncerWalk1L[]={
0,0,0x56,2|OAM_FLIP_H,
8,0,0x55,2|OAM_FLIP_H,
0,8,0x5d,2|OAM_FLIP_H,
8,8,0x5c,2|OAM_FLIP_H,
0,16,0x63,2|OAM_FLIP_H,
8,16,0x62,2|OAM_FLIP_H,
128
};

const unsigned char sprBouncerWalk2L[]={
0,0,0x58,2|OAM_FLIP_H,
8,0,0x57,2|OAM_FLIP_H,
0,8,0x5f,2|OAM_FLIP_H,
8,8,0x5e,2|OAM_FLIP_H,
0,16,0x65,2|OAM_FLIP_H,
8,16,0x64,2|OAM_FLIP_H,
128
};

const unsigned char sprBouncerWalk3L[]={
0,0,0x5a,2|OAM_FLIP_H,
8,0,0x59,2|OAM_FLIP_H,
0,8,0x60,2|OAM_FLIP_H,
8,8,0x5c,2|OAM_FLIP_H,
0,16,0x67,2|OAM_FLIP_H,
8,16,0x66,2|OAM_FLIP_H,
128
};

const unsigned char sprBouncerWalk4L[]={
0,0,0x5b,2|OAM_FLIP_H,
8,0,0x57,2|OAM_FLIP_H,
0,8,0x61,2|OAM_FLIP_H,
8,8,0x5e,2|OAM_FLIP_H,
0,16,0x69,2|OAM_FLIP_H,
8,16,0x68,2|OAM_FLIP_H,
128
};



const unsigned char sprChatterWalk1R[]={
0,0,0x6a,1,
8,0,0x6b,1,
0,8,0x7a,2,
8,8,0x7b,2,
0,16,0x8a,2,
8,16,0x8b,2,
128
};

const unsigned char sprChatterWalk2R[]={
0,0,0x6c,1,
8,0,0x6d,1,
0,8,0x7c,2,
8,8,0x7d,2,
0,16,0x8c,2,
8,16,0x8d,2,
128
};

const unsigned char sprChatterWalk3R[]={
0,0,0x6a,1,
8,0,0x6b,1,
0,8,0x7a,2,
8,8,0x7b,2,
0,16,0x8e,2,
8,16,0x8f,2,
128
};

const unsigned char sprChatterWalk4R[]={
0,0,0x6c,1,
8,0,0x6d,1,
0,8,0x7e,2,
8,8,0x7f,2,
0,16,0x90,2,
8,16,0x91,2,
128
};

const unsigned char sprChatterTalk1R[]={
0,0,0x6a,1,
8,0,0x6b,1,
0,8,0x80,2,
8,8,0x81,2,
0,16,0x92,2,
8,16,0x93,2,
128
};

const unsigned char sprChatterTalk2R[]={
0,0,0x6a,1,
8,0,0x6e,1,
0,8,0x82,2,
8,8,0x83,2,
0,16,0x92,2,
8,16,0x93,2,
128
};

const unsigned char sprChatterTalk3R[]={
0,0,0x6f,1,
8,0,0x70,1,
0,8,0x82,2,
8,8,0x83,2,
0,16,0x92,2,
8,16,0x93,2,
128
};

const unsigned char sprChatterTalk4R[]={
0,0,0x6f,1,
8,0,0x71,1,
0,8,0x7a,2,
8,8,0x84,2,
0,16,0x92,2,
8,16,0x93,2,
128
};

const unsigned char sprChatterTalk5R[]={
0,0,0x72,1,
8,0,0x73,1,
0,8,0x85,2,
8,8,0x86,2,
0,16,0x92,2,
8,16,0x93,2,
128
};

const unsigned char sprChatterTalk6R[]={
0,0,0x72,1,
8,0,0x74,1,
0,8,0x85,2,
8,8,0x87,2,
0,16,0x92,2,
8,16,0x93,2,
128
};

const unsigned char sprChatterTalk7R[]={
0,0,0x75,1,
8,0,0x76,1,
0,8,0x88,2,
8,8,0x86,2,
0,16,0x92,2,
8,16,0x93,2,
128
};

const unsigned char sprChatterTalk8R[]={
0,0,0x75,1,
8,0,0x77,1,
0,8,0x88,2,
8,8,0x87,2,
0,16,0x92,2,
8,16,0x93,2,
128
};

const unsigned char sprChatterTalk9R[]={
0,0,0x78,1,
8,0,0x79,1,
0,8,0x89,2,
8,8,0x87,2,
0,16,0x92,2,
8,16,0x93,2,
128
};

const unsigned char sprChatterWalk1L[]={
0,0,0x6b,1|OAM_FLIP_H,
8,0,0x6a,1|OAM_FLIP_H,
0,8,0x7b,2|OAM_FLIP_H,
8,8,0x7a,2|OAM_FLIP_H,
0,16,0x8b,2|OAM_FLIP_H,
8,16,0x8a,2|OAM_FLIP_H,
128
};

const unsigned char sprChatterWalk2L[]={
0,0,0x6d,1|OAM_FLIP_H,
8,0,0x6c,1|OAM_FLIP_H,
0,8,0x7d,2|OAM_FLIP_H,
8,8,0x7c,2|OAM_FLIP_H,
0,16,0x8d,2|OAM_FLIP_H,
8,16,0x8c,2|OAM_FLIP_H,
128
};

const unsigned char sprChatterWalk3L[]={
0,0,0x6b,1|OAM_FLIP_H,
8,0,0x6a,1|OAM_FLIP_H,
0,8,0x7b,2|OAM_FLIP_H,
8,8,0x7a,2|OAM_FLIP_H,
0,16,0x8f,2|OAM_FLIP_H,
8,16,0x8e,2|OAM_FLIP_H,
128
};

const unsigned char sprChatterWalk4L[]={
0,0,0x6d,1|OAM_FLIP_H,
8,0,0x6c,1|OAM_FLIP_H,
0,8,0x7f,2|OAM_FLIP_H,
8,8,0x7e,2|OAM_FLIP_H,
0,16,0x91,2|OAM_FLIP_H,
8,16,0x90,2|OAM_FLIP_H,
128
};

const unsigned char sprChatterTalk1L[]={
0,0,0x6b,1|OAM_FLIP_H,
8,0,0x6a,1|OAM_FLIP_H,
0,8,0x81,2|OAM_FLIP_H,
8,8,0x80,2|OAM_FLIP_H,
0,16,0x93,2|OAM_FLIP_H,
8,16,0x92,2|OAM_FLIP_H,
128
};

const unsigned char sprChatterTalk2L[]={
0,0,0x6e,1|OAM_FLIP_H,
8,0,0x6a,1|OAM_FLIP_H,
0,8,0x83,2|OAM_FLIP_H,
8,8,0x82,2|OAM_FLIP_H,
0,16,0x93,2|OAM_FLIP_H,
8,16,0x92,2|OAM_FLIP_H,
128
};

const unsigned char sprChatterTalk3L[]={
0,0,0x70,1|OAM_FLIP_H,
8,0,0x6f,1|OAM_FLIP_H,
0,8,0x83,2|OAM_FLIP_H,
8,8,0x82,2|OAM_FLIP_H,
0,16,0x93,2|OAM_FLIP_H,
8,16,0x92,2|OAM_FLIP_H,
128
};

const unsigned char sprChatterTalk4L[]={
0,0,0x71,1|OAM_FLIP_H,
8,0,0x6f,1|OAM_FLIP_H,
0,8,0x84,2|OAM_FLIP_H,
8,8,0x7a,2|OAM_FLIP_H,
0,16,0x93,2|OAM_FLIP_H,
8,16,0x92,2|OAM_FLIP_H,
128
};

const unsigned char sprChatterTalk5L[]={
0,0,0x73,1|OAM_FLIP_H,
8,0,0x72,1|OAM_FLIP_H,
0,8,0x86,2|OAM_FLIP_H,
8,8,0x85,2|OAM_FLIP_H,
0,16,0x93,2|OAM_FLIP_H,
8,16,0x92,2|OAM_FLIP_H,
128
};

const unsigned char sprChatterTalk6L[]={
0,0,0x74,1|OAM_FLIP_H,
8,0,0x72,1|OAM_FLIP_H,
0,8,0x87,2|OAM_FLIP_H,
8,8,0x85,2|OAM_FLIP_H,
0,16,0x93,2|OAM_FLIP_H,
8,16,0x92,2|OAM_FLIP_H,
128
};

const unsigned char sprChatterTalk7L[]={
0,0,0x76,1|OAM_FLIP_H,
8,0,0x75,1|OAM_FLIP_H,
0,8,0x86,2|OAM_FLIP_H,
8,8,0x88,2|OAM_FLIP_H,
0,16,0x93,2|OAM_FLIP_H,
8,16,0x92,2|OAM_FLIP_H,
128
};

const unsigned char sprChatterTalk8L[]={
0,0,0x77,1|OAM_FLIP_H,
8,0,0x75,1|OAM_FLIP_H,
0,8,0x87,2|OAM_FLIP_H,
8,8,0x88,2|OAM_FLIP_H,
0,16,0x93,2|OAM_FLIP_H,
8,16,0x92,2|OAM_FLIP_H,
128
};

const unsigned char sprChatterTalk9L[]={
0,0,0x79,1|OAM_FLIP_H,
8,0,0x78,1|OAM_FLIP_H,
0,8,0x87,2|OAM_FLIP_H,
8,8,0x89,2|OAM_FLIP_H,
0,16,0x93,2|OAM_FLIP_H,
8,16,0x92,2|OAM_FLIP_H,
128
};



const unsigned char sprGeekWalk1R[]={
0,0,0x99,2,
8,0,0x9a,2,
0,8,0xa1,2,
8,8,0xa2,2,
0,16,0xa7,2,
8,16,0xa8,2,
128
};

const unsigned char sprGeekWalk2R[]={
0,0,0x9b,2,
8,0,0x9c,2,
0,8,0xa3,2,
8,8,0xa4,2,
0,16,0xa9,2,
8,16,0xaa,2,
128
};

const unsigned char sprGeekWalk3R[]={
0,0,0x99,2,
8,0,0x9a,2,
0,8,0xa1,2,
8,8,0xa2,2,
0,16,0xab,2,
8,16,0xac,2,
128
};

const unsigned char sprGeekWalk4R[]={
0,0,0x9b,2,
8,0,0x9c,2,
0,8,0xa3,2,
8,8,0xa4,2,
0,16,0xad,2,
8,16,0xae,2,
128
};

const unsigned char sprGeekWalk1L[]={
0,0,0x9a,2|OAM_FLIP_H,
8,0,0x99,2|OAM_FLIP_H,
0,8,0xa2,2|OAM_FLIP_H,
8,8,0xa1,2|OAM_FLIP_H,
0,16,0xa8,2|OAM_FLIP_H,
8,16,0xa7,2|OAM_FLIP_H,
128
};

const unsigned char sprGeekWalk2L[]={
0,0,0x9c,2|OAM_FLIP_H,
8,0,0x9b,2|OAM_FLIP_H,
0,8,0xa4,2|OAM_FLIP_H,
8,8,0xa3,2|OAM_FLIP_H,
0,16,0xaa,2|OAM_FLIP_H,
8,16,0xa9,2|OAM_FLIP_H,
128
};

const unsigned char sprGeekWalk3L[]={
0,0,0x9a,2|OAM_FLIP_H,
8,0,0x99,2|OAM_FLIP_H,
0,8,0xa2,2|OAM_FLIP_H,
8,8,0xa1,2|OAM_FLIP_H,
0,16,0xac,2|OAM_FLIP_H,
8,16,0xab,2|OAM_FLIP_H,
128
};

const unsigned char sprGeekWalk4L[]={
0,0,0x9c,2|OAM_FLIP_H,
8,0,0x9b,2|OAM_FLIP_H,
0,8,0xa4,2|OAM_FLIP_H,
8,8,0xa3,2|OAM_FLIP_H,
0,16,0xae,2|OAM_FLIP_H,
8,16,0xad,2|OAM_FLIP_H,
128
};

const unsigned char sprGeekStand1R[]={
0,0,0x9d,2,
8,0,0x9e,2,
0,8,0xa5,2,
8,8,0xa6,2,
0,16,0xaf,2,
8,16,0xb0,2,
128
};

const unsigned char sprGeekStand2R[]={
0,0,0x9f,2,
8,0,0xa0,2,
0,8,0xa5,2,
8,8,0xa6,2,
0,16,0xaf,2,
8,16,0xb0,2,
128
};

const unsigned char sprGeekStand1L[]={
0,0,0x9e,2|OAM_FLIP_H,
8,0,0x9d,2|OAM_FLIP_H,
0,8,0xa6,2|OAM_FLIP_H,
8,8,0xa5,2|OAM_FLIP_H,
0,16,0xb0,2|OAM_FLIP_H,
8,16,0xaf,2|OAM_FLIP_H,
128
};

const unsigned char sprGeekStand2L[]={
0,0,0xa0,2|OAM_FLIP_H,
8,0,0x9f,2|OAM_FLIP_H,
0,8,0xa6,2|OAM_FLIP_H,
8,8,0xa5,2|OAM_FLIP_H,
0,16,0xb0,2|OAM_FLIP_H,
8,16,0xaf,2|OAM_FLIP_H,
128
};



const unsigned char sprManBoxWalk1R[]={
0,0,0xb1,2,
8,0,0xb2,2,
0,8,0xb6,2,
8,8,0xb7,2,
0,16,0xbd,2,
8,16,0xbe,2,
128
};

const unsigned char sprManBoxWalk2R[]={
0,0,0xb3,2,
8,0,0xb4,2,
0,8,0xb8,2,
8,8,0xb9,2,
0,16,0xbf,2,
8,16,0xc0,2,
128
};

const unsigned char sprManBoxWalk3R[]={
0,0,0xb1,2,
8,0,0xb2,2,
0,8,0xba,2,
8,8,0xbb,2,
0,16,0xc1,2,
8,16,0xc2,2,
128
};

const unsigned char sprManBoxWalk4R[]={
0,0,0xb3,2,
8,0,0xb4,2,
0,8,0xb8,2,
8,8,0xbc,2,
0,16,0xc3,2,
8,16,0xc4,2,
128
};

const unsigned char sprManBoxWalk1L[]={
0,0,0xb2,2|OAM_FLIP_H,
8,0,0xb1,2|OAM_FLIP_H,
0,8,0xb7,2|OAM_FLIP_H,
8,8,0xb6,2|OAM_FLIP_H,
0,16,0xbe,2|OAM_FLIP_H,
8,16,0xbd,2|OAM_FLIP_H,
128
};

const unsigned char sprManBoxWalk2L[]={
0,0,0xb4,2|OAM_FLIP_H,
8,0,0xb3,2|OAM_FLIP_H,
0,8,0xb9,2|OAM_FLIP_H,
8,8,0xb8,2|OAM_FLIP_H,
0,16,0xc0,2|OAM_FLIP_H,
8,16,0xbf,2|OAM_FLIP_H,
128
};

const unsigned char sprManBoxWalk3L[]={
0,0,0xb2,2|OAM_FLIP_H,
8,0,0xb1,2|OAM_FLIP_H,
0,8,0xbb,2|OAM_FLIP_H,
8,8,0xba,2|OAM_FLIP_H,
0,16,0xc2,2|OAM_FLIP_H,
8,16,0xc1,2|OAM_FLIP_H,
128
};

const unsigned char sprManBoxWalk4L[]={
0,0,0xb4,2|OAM_FLIP_H,
8,0,0xb3,2|OAM_FLIP_H,
0,8,0xbc,2|OAM_FLIP_H,
8,8,0xb8,2|OAM_FLIP_H,
0,16,0xc4,2|OAM_FLIP_H,
8,16,0xc3,2|OAM_FLIP_H,
128
};



const unsigned char sprDibrovWalk1R[]={
0,0,0xc7,2,
8,0,0xc8,2,
0,8,0xcb,2,
8,8,0xcc,2,
0,16,0xd0,2,
8,16,0xd1,2,
128
};

const unsigned char sprDibrovWalk2R[]={
0,0,0xc9,2,
8,0,0xca,2,
0,8,0xcd,2,
8,8,0xce,2,
0,16,0xd2,2,
8,16,0xd3,2,
128
};

const unsigned char sprDibrovWalk3R[]={
0,0,0xc7,2,
8,0,0xc8,2,
0,8,0xcb,2,
8,8,0xcc,2,
0,16,0xd4,2,
8,16,0xd5,2,
128
};

const unsigned char sprDibrovWalk4R[]={
0,0,0xc9,2,
8,0,0xca,2,
0,8,0xcf,2,
8,8,0xce,2,
0,16,0xd6,2,
8,16,0xd7,2,
128
};

const unsigned char sprDibrovWalk1L[]={
0,0,0xc8,2|OAM_FLIP_H,
8,0,0xc7,2|OAM_FLIP_H,
0,8,0xcc,2|OAM_FLIP_H,
8,8,0xcb,2|OAM_FLIP_H,
0,16,0xd1,2|OAM_FLIP_H,
8,16,0xd0,2|OAM_FLIP_H,
128
};

const unsigned char sprDibrovWalk2L[]={
0,0,0xca,2|OAM_FLIP_H,
8,0,0xc9,2|OAM_FLIP_H,
0,8,0xce,2|OAM_FLIP_H,
8,8,0xcd,2|OAM_FLIP_H,
0,16,0xd3,2|OAM_FLIP_H,
8,16,0xd2,2|OAM_FLIP_H,
128
};

const unsigned char sprDibrovWalk3L[]={
0,0,0xc8,2|OAM_FLIP_H,
8,0,0xc7,2|OAM_FLIP_H,
0,8,0xcc,2|OAM_FLIP_H,
8,8,0xcb,2|OAM_FLIP_H,
0,16,0xd5,2|OAM_FLIP_H,
8,16,0xd4,2|OAM_FLIP_H,
128
};

const unsigned char sprDibrovWalk4L[]={
0,0,0xca,2|OAM_FLIP_H,
8,0,0xc9,2|OAM_FLIP_H,
0,8,0xce,2|OAM_FLIP_H,
8,8,0xcf,2|OAM_FLIP_H,
0,16,0xd7,2|OAM_FLIP_H,
8,16,0xd6,2|OAM_FLIP_H,
128
};



const unsigned char sprSoundTest[]={
0,0,0x26,2,
8,0,0x38,2,
48,0,0x22,2,
56,0,0x27,2,
64,0,0x2d,2,
128
};