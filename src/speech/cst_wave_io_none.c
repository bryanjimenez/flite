/*************************************************************************/
/*                                                                       */
/*                  Language Technologies Institute                      */
/*                     Carnegie Mellon University                        */
/*                         Copyright (c) 2000                            */
/*                        All Rights Reserved.                           */
/*                                                                       */
/*  Permission is hereby granted, free of charge, to use and distribute  */
/*  this software and its documentation without restriction, including   */
/*  without limitation the rights to use, copy, modify, merge, publish,  */
/*  distribute, sublicense, and/or sell copies of this work, and to      */
/*  permit persons to whom this work is furnished to do so, subject to   */
/*  the following conditions:                                            */
/*   1. The code must retain the above copyright notice, this list of    */
/*      conditions and the following disclaimer.                         */
/*   2. Any modifications must be clearly marked as such.                */
/*   3. Original authors' names are not deleted.                         */
/*   4. The authors' names are not used to endorse or promote products   */
/*      derived from this software without specific prior written        */
/*      permission.                                                      */
/*                                                                       */
/*  CARNEGIE MELLON UNIVERSITY AND THE CONTRIBUTORS TO THIS WORK         */
/*  DISCLAIM ALL WARRANTIES WITH REGARD TO THIS SOFTWARE, INCLUDING      */
/*  ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS, IN NO EVENT   */
/*  SHALL CARNEGIE MELLON UNIVERSITY NOR THE CONTRIBUTORS BE LIABLE      */
/*  FOR ANY SPECIAL, INDIRECT OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES    */
/*  WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN   */
/*  AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION,          */
/*  ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF       */
/*  THIS SOFTWARE.                                                       */
/*                                                                       */
/*************************************************************************/
/*             Author:  Alan W Black (awb@cs.cmu.edu)                    */
/*               Date:  August 2000                                      */
/*************************************************************************/
/*                                                                       */
/*  Waveforms                                                            */
/*                                                                       */
/*************************************************************************/
#include "cst_string.h"
#include "cst_wave.h"
#include "cst_file.h"

void cst_wave_resample(cst_wave *w, int sample_rate)
{
    /* This is here so that it won't necessarily be linked in tight-space */
    /* platforms like PalmOS                                              */

    cst_rateconv *filt;
    int up, down;
    short *in;
    const short *inptr;
    short *outptr;
    int n, insize, outsize;

    /* Sure, we could take the GCD.  In practice, though, this
       gives us what we want and makes things go faster. */
    down = w->sample_rate / 1000;
    up = sample_rate / 1000;

    if (up < 1 || down < 1) {
	cst_errmsg("cst_wave_resample: invalid input/output sample rates (%d, %d)\n",
		   up * 1000, down * 1000);
	cst_error();
    }

    filt = new_rateconv(up, down, w->num_channels);

    inptr = in = w->samples;
    insize = w->num_samples;

    w->num_samples = w->num_samples * up / down + 2048;
    w->samples = cst_alloc(short, w->num_samples * w->num_channels);
    w->sample_rate = sample_rate;

    outptr = w->samples;
    outsize = w->num_samples;

    while ((n = cst_rateconv_in(filt, inptr, insize)) > 0) {
	inptr += n;
	insize -= n;

	while ((n = cst_rateconv_out(filt, outptr, outsize)) > 0) {
	    outptr += n;
	    outsize -= n;
	}
    }
    cst_rateconv_leadout(filt);
    while ((n = cst_rateconv_out(filt, outptr, outsize)) > 0) {
	outptr += n;
	outsize -= n;
    }

    cst_free(in);
    delete_rateconv(filt);

}


int cst_wave_save(cst_wave *w,const char *filename,const char *type)
{
    return 0;
}

int cst_wave_save_raw(cst_wave *w, const char *filename)
{
    return 0;
}

int cst_wave_save_raw_fd(cst_wave *w, cst_file fd)
{
    return 0;
}




int cst_wave_append_riff(cst_wave *w,const char *filename)
{
    return 0;
}


int cst_wave_save_riff(cst_wave *w,const char *filename) {
    return 0;
}

int cst_wave_save_riff_fd(cst_wave *w, cst_file fd) {
    return 0;
}

int cst_wave_load_raw(cst_wave *w,const char *filename,
		      const char *bo, int sample_rate){
    return 0;
}


int cst_wave_load_raw_fd(cst_wave *w, cst_file fd,
			 const char *bo, int sample_rate)
{
    return 0;
}

int cst_wave_load_riff(cst_wave *w,const char *filename)
{
    return 0;
}

int cst_wave_load_riff_header(cst_wave_header *header,cst_file fd)
{
    return 0;
}


int cst_wave_load_riff_fd(cst_wave *w,cst_file fd)
{
    return 0;
}

