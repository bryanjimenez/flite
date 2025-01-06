/*************************************************************************/
/*                                                                       */
/*    Rust-c entry-point for wasm32-unknown-unknown.                     */
/*                                                                       */
/*       Authors:  Bryan Jimenez                                         */
/*          Date:  Dec 2024                                              */
/*************************************************************************/

#include "cst_synth.h"
#include "flite_wasm.h"

#define WASM_EXPORT __attribute__((visibility("default")))

cst_voice *register_cmu_us_kal(const char *voxdir);

result_wave* WASM_EXPORT synth_audio_basic(const char *text){
    cst_voice *voice = register_cmu_us_kal(NULL);
    
    cst_utterance *u = new_utterance();
    feat_set_string(u->features,"input_text",text);
    utt_init(u, voice);

    if ((*utt_synth)(u) == NULL)
    {
        delete_utterance(u);
        return NULL;
    }

    cst_wave *w= val_wave(feat_val(u->features,"wave"));
    result_wave *o = (result_wave*)alloc_result_wave(w->num_channels, w->sample_rate, w->num_samples, w->samples);


    delete_utterance(u);

    wasm_alloc_shrink();

    return o;
}
