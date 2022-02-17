/**********************************************************/
/* inverse two dimensional DCT, Chen-Wang algorithm       */
/* (cf. IEEE ASSP-32, pp. 803-816, Aug. 1984)             */
/* 32-bit integer arithmetic (8 bit coefficients)         */
/* 11 mults, 29 adds per DCT                              */
/*                                      sE, 18.8.91       */
/**********************************************************/
/* coefficients extended to 12 bit for IEEE1180-1990      */
/* compliance                           sE,  2.1.94       */
/**********************************************************/

/* this code assumes >> to be a two's-complement arithmetic */
/* right shift: (-2)>>1 == -1 , (-3)>>1 == -2               */

#include "config.h"

#define W1 2841 /* 2048*sqrt(2)*cos(1*pi/16) */
#define W2 2676 /* 2048*sqrt(2)*cos(2*pi/16) */
#define W3 2408 /* 2048*sqrt(2)*cos(3*pi/16) */
#define W5 1609 /* 2048*sqrt(2)*cos(5*pi/16) */
#define W6 1108 /* 2048*sqrt(2)*cos(6*pi/16) */
#define W7 565  /* 2048*sqrt(2)*cos(7*pi/16) */

/* global declarations */
//void Initialize_Fast_IDCT _ANSI_ARGS_((void));
//void Fast_IDCT _ANSI_ARGS_((short *block));

/* private data */
//static short iclip[1024]; /* clipping table */
//static short *iclp;
static short iclip(int i);

/* private prototypes */
//static void idctrow _ANSI_ARGS_((short *blk));
//static void idctcol _ANSI_ARGS_((short *blk));

/* row (horizontal) IDCT
 *
 *           7                       pi         1
 * dst[k] = sum c[l] * src[l] * cos( -- * ( k + - ) * l )
 *          l=0                      8          2
 *
 * where: c[0]    = 128
 *        c[1..7] = 128*sqrt(2)
 */

static void idctrow(short b0, short b1, short b2, short b3, short b4, short b5, short b6, short b7,
                    short *r0, short *r1, short *r2, short *r3, short *r4, short *r5, short *r6, short *r7)
{
  int x0, x1, x2, x3, x4, x5, x6, x7, x8;

  /* shortcut */
  if (!((x1 = b4<<11) | (x2 = b6) | (x3 = b2) |
        (x4 = b1) | (x5 = b7) | (x6 = b5) | (x7 = b3)))
  {
    *r0=*r1=*r2=*r3=*r4=*r5=*r6=*r7=b0<<3;
    return;
  }

  x0 = (b0<<11) + 128; /* for proper rounding in the fourth stage */

  /* first stage */
  x8 = W7*(x4+x5);
  x4 = x8 + (W1-W7)*x4;
  x5 = x8 - (W1+W7)*x5;
  x8 = W3*(x6+x7);
  x6 = x8 - (W3-W5)*x6;
  x7 = x8 - (W3+W5)*x7;

  /* second stage */
  x8 = x0 + x1;
  x0 -= x1;
  x1 = W6*(x3+x2);
  x2 = x1 - (W2+W6)*x2;
  x3 = x1 + (W2-W6)*x3;
  x1 = x4 + x6;
  x4 -= x6;
  x6 = x5 + x7;
  x5 -= x7;

  /* third stage */
  x7 = x8 + x3;
  x8 -= x3;
  x3 = x0 + x2;
  x0 -= x2;
  x2 = (181*(x4+x5)+128)>>8;
  x4 = (181*(x4-x5)+128)>>8;

  /* fourth stage */
  *r0 = (x7+x1)>>8;
  *r1 = (x3+x2)>>8;
  *r2 = (x0+x4)>>8;
  *r3 = (x8+x6)>>8;
  *r4 = (x8-x6)>>8;
  *r5 = (x0-x4)>>8;
  *r6 = (x3-x2)>>8;
  *r7 = (x7-x1)>>8;
}

/* column (vertical) IDCT
 *
 *             7                         pi         1
 * dst[8*k] = sum c[l] * src[8*l] * cos( -- * ( k + - ) * l )
 *            l=0                        8          2
 *
 * where: c[0]    = 1/1024
 *        c[1..7] = (1/1024)*sqrt(2)
 */
static void idctcol(short b0, short b1, short b2, short b3, short b4, short b5, short b6, short b7,
                    short *c0, short *c1, short *c2, short *c3, short *c4, short *c5, short *c6, short *c7)
{
  int x0, x1, x2, x3, x4, x5, x6, x7, x8;

  /* shortcut */
  if (!((x1 = (b4<<8)) | (x2 = b6) | (x3 = b2) |
        (x4 = b1) | (x5 = b7) | (x6 = b5) | (x7 = b3)))
  {
    *c0=*c1=*c2=*c3=*c4=*c5=*c6=*c7=
      iclip((b0+32)>>6);
    return;
  }

  x0 = (b0<<8) + 8192;

  /* first stage */
  x8 = W7*(x4+x5) + 4;
  x4 = (x8+(W1-W7)*x4)>>3;
  x5 = (x8-(W1+W7)*x5)>>3;
  x8 = W3*(x6+x7) + 4;
  x6 = (x8-(W3-W5)*x6)>>3;
  x7 = (x8-(W3+W5)*x7)>>3;

  /* second stage */
  x8 = x0 + x1;
  x0 -= x1;
  x1 = W6*(x3+x2) + 4;
  x2 = (x1-(W2+W6)*x2)>>3;
  x3 = (x1+(W2-W6)*x3)>>3;
  x1 = x4 + x6;
  x4 -= x6;
  x6 = x5 + x7;
  x5 -= x7;

  /* third stage */
  x7 = x8 + x3;
  x8 -= x3;
  x3 = x0 + x2;
  x0 -= x2;
  x2 = (181*(x4+x5)+128)>>8;
  x4 = (181*(x4-x5)+128)>>8;

  /* fourth stage */
  *c0 = iclip((x7+x1)>>14);
  *c1 = iclip((x3+x2)>>14);
  *c2 = iclip((x0+x4)>>14);
  *c3 = iclip((x8+x6)>>14);
  *c4 = iclip((x8-x6)>>14);
  *c5 = iclip((x0-x4)>>14);
  *c6 = iclip((x3-x2)>>14);
  *c7 = iclip((x7-x1)>>14);
}

/* two dimensional inverse discrete cosine transform */
/*void Fast_IDCT(block)
short *block;
{
  int i;

  for (i=0; i<8; i++)
    idctrow(block+8*i);

  for (i=0; i<8; i++)
    idctcol(block+i);
}*/

void Top_Fast_IDCT(long long ibl[8], long long ibh[8], long long obl[8], long long obh[8])
{
#pragma HLS INTERFACE axis port=ibl
#pragma HLS INTERFACE axis port=ibh
#pragma HLS INTERFACE axis port=obl
#pragma HLS INTERFACE axis port=obh
#pragma HLS PIPELINE
  int i, j;
  short intl_block[64];
  for (i=0; i<8; i++) {
    for (j=0; j<4; j++) {
      intl_block[i * 8 + j]     = ibl[i] >> (j * 16);
      intl_block[i * 8 + j + 4] = ibh[i] >> (j * 16);
    }
  }

  for (i=0; i<8; i++) {
    idctrow(intl_block[8*i], intl_block[8*i+1], intl_block[8*i+2], intl_block[8*i+3], intl_block[8*i+4], intl_block[8*i+5], intl_block[8*i+6], intl_block[8*i+7],
            &(intl_block[8*i]), &(intl_block[8*i+1]), &(intl_block[8*i+2]), &(intl_block[8*i+3]), &(intl_block[8*i+4]), &(intl_block[8*i+5]), &(intl_block[8*i+6]), &(intl_block[8*i+7]));
  }

  for (i=0; i<8; i++) {
    idctcol(intl_block[i+0*8], intl_block[i+1*8], intl_block[i+2*8], intl_block[i+3*8], intl_block[i+4*8], intl_block[i+5*8], intl_block[i+6*8], intl_block[i+7*8],
            &(intl_block[i+0*8]), &(intl_block[i+1*8]), &(intl_block[i+2*8]), &(intl_block[i+3*8]), &(intl_block[i+4*8]), &(intl_block[i+5*8]), &(intl_block[i+6*8]), &(intl_block[i+7*8]));
  }

  for (i=0; i<8; i++) {
    long long templ = 0, temph = 0;
    for (j=0; j<4; j++) {
      templ |= (long long)(unsigned short)intl_block[i * 8 + j] << (j * 16);
      temph |= (long long)(unsigned short)intl_block[i * 8 + j + 4] << (j * 16);
    }
    obl[i] = templ;
    obh[i] = temph;
  }
}

/*void Initialize_Fast_IDCT()
{
  int i;

  iclp = iclip+512;
  for (i= -512; i<512; i++)
    iclp[i] = (i<-256) ? -256 : ((i>255) ? 255 : i);
}*/

static short iclip(int i)
{
  if (i < -256) return -256;
  else if (i > 255) return 255;
  else return i;
}
