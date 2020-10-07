/*
 * Copyright (c), Recep Aslantas.
 * MIT License (MIT), http://opensource.org/licenses/MIT
 */

#ifndef cmt_pixelformat_h
#define cmt_pixelformat_h

#include "common.h"

typedef enum MtPixelFormat {
  MtPixelFormatInvalid                = 0,

  /* Normal 8 bit formats */
  MtPixelFormatA8Unorm                = 1,
  MtPixelFormatR8Unorm                = 10,
  MtPixelFormatR8Unorm_sRGB           = 11,
  MtPixelFormatR8Snorm                = 12,
  MtPixelFormatR8Uint                 = 13,
  MtPixelFormatR8Sint                 = 14,

  /* Normal 16 bit formats */
  MtPixelFormatR16Unorm               = 20,
  MtPixelFormatR16Snorm               = 22,
  MtPixelFormatR16Uint                = 23,
  MtPixelFormatR16Sint                = 24,
  MtPixelFormatR16Float               = 25,

  MtPixelFormatRG8Unorm               = 30,
  MtPixelFormatRG8Unorm_sRGB          = 31,
  MtPixelFormatRG8Snorm               = 32,
  MtPixelFormatRG8Uint                = 33,
  MtPixelFormatRG8Sint                = 34,

  /* Packed 16 bit formats */
  MtPixelFormatB5G6R5Unorm            = 40,
  MtPixelFormatA1BGR5Unorm            = 41,
  MtPixelFormatABGR4Unorm             = 42,
  MtPixelFormatBGR5A1Unorm            = 43,

  /* Normal 32 bit formats */
  MtPixelFormatR32Uint                = 53,
  MtPixelFormatR32Sint                = 54,
  MtPixelFormatR32Float               = 55,
  MtPixelFormatRG16Unorm              = 60,
  MtPixelFormatRG16Snorm              = 62,
  MtPixelFormatRG16Uint               = 63,
  MtPixelFormatRG16Sint               = 64,
  MtPixelFormatRG16Float              = 65,
  MtPixelFormatRGBA8Unorm             = 70,
  MtPixelFormatRGBA8Unorm_sRGB        = 71,
  MtPixelFormatRGBA8Snorm             = 72,
  MtPixelFormatRGBA8Uint              = 73,
  MtPixelFormatRGBA8Sint              = 74,
  MtPixelFormatBGRX8Unorm             = 75,
  MtPixelFormatBGRA8Unorm             = 80,
  MtPixelFormatBGRA8Unorm_sRGB        = 81,

  /* Packed 32 bit formats */
  MtPixelFormatRGB10A2Unorm           = 90,
  MtPixelFormatRGB10A2Uint            = 91,
  MtPixelFormatRG11B10Float           = 92,
  MtPixelFormatRGB9E5Float            = 93,
  MtPixelFormatBGR10A2Unorm           = 94,
  MtPixelFormatBGR10_XR               = 554,
  MtPixelFormatBGR10_XR_sRGB          = 555,

  /* Normal 64 bit formats */

  MtPixelFormatRG32Uint               = 103,
  MtPixelFormatRG32Sint               = 104,
  MtPixelFormatRG32Float              = 105,
  MtPixelFormatRGBA16Unorm            = 110,
  MtPixelFormatRGBA16Snorm            = 112,
  MtPixelFormatRGBA16Uint             = 113,
  MtPixelFormatRGBA16Sint             = 114,
  MtPixelFormatRGBA16Float            = 115,
  MtPixelFormatBGRA10_XR              = 552,
  MtPixelFormatBGRA10_XR_sRGB         = 553,

  /* Normal 128 bit formats */

  MtPixelFormatRGBA32Uint             = 123,
  MtPixelFormatRGBA32Sint             = 124,
  MtPixelFormatRGBA32Float            = 125,

  /* Compressed formats. */

  /* S3TC/DXT */
  MtPixelFormatBC1_RGBA               = 130,
  MtPixelFormatBC1_RGBA_sRGB          = 131,
  MtPixelFormatBC2_RGBA               = 132,
  MtPixelFormatBC2_RGBA_sRGB          = 133,
  MtPixelFormatBC3_RGBA               = 134,
  MtPixelFormatBC3_RGBA_sRGB          = 135,

  /* RGTC */
  MtPixelFormatBC4_RUnorm             = 140,
  MtPixelFormatBC4_RSnorm             = 141,
  MtPixelFormatBC5_RGUnorm            = 142,
  MtPixelFormatBC5_RGSnorm            = 143,

  /* BPTC */
  MtPixelFormatBC6H_RGBFloat          = 150,
  MtPixelFormatBC6H_RGBUfloat         = 151,
  MtPixelFormatBC7_RGBAUnorm          = 152,
  MtPixelFormatBC7_RGBAUnorm_sRGB     = 153,

  /* PVRTC */
  MtPixelFormatPVRTC_RGB_2BPP         = 160,
  MtPixelFormatPVRTC_RGB_2BPP_sRGB    = 161,
  MtPixelFormatPVRTC_RGB_4BPP         = 162,
  MtPixelFormatPVRTC_RGB_4BPP_sRGB    = 163,
  MtPixelFormatPVRTC_RGBA_2BPP        = 164,
  MtPixelFormatPVRTC_RGBA_2BPP_sRGB   = 165,
  MtPixelFormatPVRTC_RGBA_4BPP        = 166,
  MtPixelFormatPVRTC_RGBA_4BPP_sRGB   = 167,

  /* ETC2 */
  MtPixelFormatEAC_R11Unorm           = 170,
  MtPixelFormatEAC_R11Snorm           = 172,
  MtPixelFormatEAC_RG11Unorm          = 174,
  MtPixelFormatEAC_RG11Snorm          = 176,
  MtPixelFormatEAC_RGBA8              = 178,
  MtPixelFormatEAC_RGBA8_sRGB         = 179,

  MtPixelFormatETC2_RGB8              = 180,
  MtPixelFormatETC2_RGB8_sRGB         = 181,
  MtPixelFormatETC2_RGB8A1            = 182,
  MtPixelFormatETC2_RGB8A1_sRGB       = 183,

  /* ASTC */
  MtPixelFormatASTC_4x4_sRGB          = 186,
  MtPixelFormatASTC_5x4_sRGB          = 187,
  MtPixelFormatASTC_5x5_sRGB          = 188,
  MtPixelFormatASTC_6x5_sRGB          = 189,
  MtPixelFormatASTC_6x6_sRGB          = 190,
  MtPixelFormatASTC_8x5_sRGB          = 192,
  MtPixelFormatASTC_8x6_sRGB          = 193,
  MtPixelFormatASTC_8x8_sRGB          = 194,
  MtPixelFormatASTC_10x5_sRGB         = 195,
  MtPixelFormatASTC_10x6_sRGB         = 196,
  MtPixelFormatASTC_10x8_sRGB         = 197,
  MtPixelFormatASTC_10x10_sRGB        = 198,
  MtPixelFormatASTC_12x10_sRGB        = 199,
  MtPixelFormatASTC_12x12_sRGB        = 200,

  MtPixelFormatASTC_4x4_LDR           = 204,
  MtPixelFormatASTC_5x4_LDR           = 205,
  MtPixelFormatASTC_5x5_LDR           = 206,
  MtPixelFormatASTC_6x5_LDR           = 207,
  MtPixelFormatASTC_6x6_LDR           = 208,
  MtPixelFormatASTC_8x5_LDR           = 210,
  MtPixelFormatASTC_8x6_LDR           = 211,
  MtPixelFormatASTC_8x8_LDR           = 212,
  MtPixelFormatASTC_10x5_LDR          = 213,
  MtPixelFormatASTC_10x6_LDR          = 214,
  MtPixelFormatASTC_10x8_LDR          = 215,
  MtPixelFormatASTC_10x10_LDR         = 216,
  MtPixelFormatASTC_12x10_LDR         = 217,
  MtPixelFormatASTC_12x12_LDR         = 218,
  MtPixelFormatGBGR422                = 240,
  MtPixelFormatBGRG422                = 241,

  /* Depth */
  MtPixelFormatDepth16Unorm           = 250,
  MtPixelFormatDepth32Float           = 252,

  /* Stencil */
  MtPixelFormatStencil8               = 253,

  /* Depth Stencil */
  MtPixelFormatDepth24Unorm_Stencil8  = 255,
  MtPixelFormatDepth32Float_Stencil8  = 260,
  MtPixelFormatX32_Stencil8           = 261,
  MtPixelFormatX24_Stencil8           = 262
} MtPixelFormat;

#endif /* cmt_pixelformat_h */
