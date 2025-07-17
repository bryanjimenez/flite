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

// Expose mechanism to deallocate cached voice
#ifdef VALGRIND_TEST
cst_voice *selected_voice = NULL;

int WASM_EXPORT deallocate_voice(){
    delete_voice(selected_voice);

// use Flite's built-in malloc usage summary
#ifdef CST_DEBUG_MALLOC
    cst_alloc_debug_summary();
#endif
    return 0;
}
#endif /* VALGRIND_TEST */

result_wave* WASM_EXPORT synth_audio_basic(const char *text){
    cst_voice *voice = register_cmu_us_kal(NULL);

    #ifdef VALGRIND_TEST
    selected_voice = voice;
    #endif /* VALGRIND_TEST */

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

    // delete_utterance performs delete_wave(w);
    delete_utterance(u);
    return o;
}
