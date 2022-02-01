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
#include "stdio.h"

#define W1 2841 /* 2048*sqrt(2)*cos(1*pi/16) */
#define W2 2676 /* 2048*sqrt(2)*cos(2*pi/16) */
#define W3 2408 /* 2048*sqrt(2)*cos(3*pi/16) */
#define W5 1609 /* 2048*sqrt(2)*cos(5*pi/16) */
#define W6 1108 /* 2048*sqrt(2)*cos(6*pi/16) */
#define W7 565  /* 2048*sqrt(2)*cos(7*pi/16) */

/* global declarations */
void Initialize_Fast_IDCT _ANSI_ARGS_((void));
void Fast_IDCT _ANSI_ARGS_((short *block));

/* private data */
//static short iclip[1024]; /* clipping table */
//static short *iclp;
static short iclip(int i);

/* private prototypes */
static void idctrow _ANSI_ARGS_((short *blk));
static void idctcol _ANSI_ARGS_((short *blk));

/* row (horizontal) IDCT
 *
 *           7                       pi         1
 * dst[k] = sum c[l] * src[l] * cos( -- * ( k + - ) * l )
 *          l=0                      8          2
 *
 * where: c[0]    = 128
 *        c[1..7] = 128*sqrt(2)
 */

static void idctrow(blk)
short blk[8];
{
  int x0, x1, x2, x3, x4, x5, x6, x7, x8;

  /* shortcut */
  if (!((x1 = blk[4]<<11) | (x2 = blk[6]) | (x3 = blk[2]) |
        (x4 = blk[1]) | (x5 = blk[7]) | (x6 = blk[5]) | (x7 = blk[3])))
  {
    blk[0]=blk[1]=blk[2]=blk[3]=blk[4]=blk[5]=blk[6]=blk[7]=blk[0]<<3;
    return;
  }

  x0 = (blk[0]<<11) + 128; /* for proper rounding in the fourth stage */
//printf("(0) x0=0x%x x1=0x%x x2=0x%x x3=0x%x x4=0x%x x5=0x%x x6=0x%x x7=0x%x x8=0x%x\n", x0, x1, x2, x3, x4, x5, x6, x7, x8);
  /* first stage */
  x8 = W7*(x4+x5);
  x4 = x8 + (W1-W7)*x4;
  x5 = x8 - (W1+W7)*x5;
  x8 = W3*(x6+x7);
  x6 = x8 - (W3-W5)*x6;
  x7 = x8 - (W3+W5)*x7;
//printf("(1) x0=0x%x x1=0x%x x2=0x%x x3=0x%x x4=0x%x x5=0x%x x6=0x%x x7=0x%x x8=0x%x\n", x0, x1, x2, x3, x4, x5, x6, x7, x8);
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
//printf("(2) x0=0x%x x1=0x%x x2=0x%x x3=0x%x x4=0x%x x5=0x%x x6=0x%x x7=0x%x x8=0x%x\n", x0, x1, x2, x3, x4, x5, x6, x7, x8);
  /* third stage */
  x7 = x8 + x3;
  x8 -= x3;
  x3 = x0 + x2;
  x0 -= x2;
  x2 = (181*(x4+x5)+128)>>8;
  x4 = (181*(x4-x5)+128)>>8;
//printf("(3) x0=0x%x x1=0x%x x2=0x%x x3=0x%x x4=0x%x x5=0x%x x6=0x%x x7=0x%x x8=0x%x\n", x0, x1, x2, x3, x4, x5, x6, x7, x8);
  /* fourth stage */
  blk[0] = (x7+x1)>>8;
  blk[1] = (x3+x2)>>8;
  blk[2] = (x0+x4)>>8;
  blk[3] = (x8+x6)>>8;
  blk[4] = (x8-x6)>>8;
  blk[5] = (x0-x4)>>8;
  blk[6] = (x3-x2)>>8;
  blk[7] = (x7-x1)>>8;
//for(int i = 0; i < 9; i++) printf("blk[%d]=0x%x\n", i, blk[i]);
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
static void idctcol(blk)
short blk[8];
{
  int x0, x1, x2, x3, x4, x5, x6, x7, x8;

  /* shortcut */
  if (!((x1 = (blk[8*4]<<8)) | (x2 = blk[8*6]) | (x3 = blk[8*2]) |
        (x4 = blk[8*1]) | (x5 = blk[8*7]) | (x6 = blk[8*5]) | (x7 = blk[8*3])))
  {
    blk[8*0]=//blk[8*1]=blk[8*2]=blk[8*3]=blk[8*4]=blk[8*5]=blk[8*6]=blk[8*7]=
      iclip((blk[8*0]+32)>>6);
    return;
  }

  x0 = (blk[8*0]<<8) + 8192;
printf("(0) x0=0x%x x1=0x%x x2=0x%x x3=0x%x x4=0x%x x5=0x%x x6=0x%x x7=0x%x x8=0x%x\n", x0, x1, x2, x3, x4, x5, x6, x7, x8);
  /* first stage */
  x8 = W7*(x4+x5) + 4;
  x4 = (x8+(W1-W7)*x4)>>3;
  x5 = (x8-(W1+W7)*x5)>>3;
  x8 = W3*(x6+x7) + 4;
  x6 = (x8-(W3-W5)*x6)>>3;
  x7 = (x8-(W3+W5)*x7)>>3;
printf("(1) x0=0x%x x1=0x%x x2=0x%x x3=0x%x x4=0x%x x5=0x%x x6=0x%x x7=0x%x x8=0x%x\n", x0, x1, x2, x3, x4, x5, x6, x7, x8);
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
printf("(2) x0=0x%x x1=0x%x x2=0x%x x3=0x%x x4=0x%x x5=0x%x x6=0x%x x7=0x%x x8=0x%x\n", x0, x1, x2, x3, x4, x5, x6, x7, x8);
  /* third stage */
  x7 = x8 + x3;
  x8 -= x3;
  x3 = x0 + x2;
  x0 -= x2;
  x2 = (181*(x4+x5)+128)>>8;
  x4 = (181*(x4-x5)+128)>>8;
printf("(3) x0=0x%x x1=0x%x x2=0x%x (%d) x3=0x%x (%d) x4=0x%x x5=0x%x x6=0x%x x7=0x%x x8=0x%x\n", x0, x1, x2, x2, x3, x3, x4, x5, x6, x7, x8);
  /* fourth stage */
  blk[8*0] = iclip((x7+x1)>>14);
  blk[8*1] = iclip((x3+x2)>>14);
  blk[8*2] = iclip((x0+x4)>>14);
  blk[8*3] = iclip((x8+x6)>>14);
  blk[8*4] = iclip((x8-x6)>>14);
  blk[8*5] = iclip((x0-x4)>>14);
  blk[8*6] = iclip((x3-x2)>>14);
  blk[8*7] = iclip((x7-x1)>>14);
for(int i = 0; i < 8; i++) printf("blk[%d]=0x%x (%d)\n", i, blk[8*i], blk[8*i]);
//printf("test=%x (iclp=%x)\n", (x3+x2)>>14, iclp[(x3+x2)>>14]);
}

/* two dimensional inverse discrete cosine transform */
void Fast_IDCT(block)
short *block;
{
  int i;

  for (i=0; i<8; i++)
    idctrow(block+8*i);

  for (i=0; i<8; i++)
    idctcol(block+i);
}

void Top_Fast_IDCT(short block[64], short out_block[64])
{
#pragma HLS INTERFACE axis port=block
#pragma HLS INTERFACE axis port=out_block
	  int i;
	  short intl_block[64];
      for (i=0; i<64; i++)
        intl_block[i] = block[i];

	  for (i=0; i<8; i++)
	    idctrow(intl_block+8*i);

	  for (i=0; i<8; i++)
	    idctcol(intl_block+i);

      for (i=0; i<64; i++)
        out_block[i] = intl_block[i];
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
  else return 255;
}

short block[64];
int main (void)
{
  int i;
//  #pragma HLS PIPELINE style=flp
//  pragma HLS DATAFLOW
  for(i = 0; i < 64; i++) {
    block[i] = i;
    printf("%d ", block[i]);
  } printf("\n");
  //Initialize_Fast_IDCT();
  Fast_IDCT(block);
  for(i = 0; i < 64; i++) {
    printf("%x ", block[i]);
  } printf("\n");
  return 0;
}