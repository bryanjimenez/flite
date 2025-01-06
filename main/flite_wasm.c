#include "cst_synth.h"
#include "flite_wasm.h"

#define WASM_EXPORT __attribute__((visibility("default")))

// ----------------------../lang/cmu_us_kal/cmu_us_kal.c
cst_voice *register_cmu_us_kal(const char *voxdir);
// ----------------------cmu_us_kal.c

result_wave* WASM_EXPORT synth_audio_basic(const char *text){
    #ifndef WASM_NO_LIB
    printf("synth_audio_basic\n");
    #endif /* WASM_NO_LIB */

    // cst_features *extra_feats = new_features();

    // cst_val *voice_list = cons_val(voice_val(register_cmu_us_kal(NULL)),voice_list);
    // cst_voice *voice = val_voice(val_car(voice_list));
    cst_voice *voice = register_cmu_us_kal(NULL);
    // feat_copy_into(extra_feats,voice->features);
    
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
    // delete_wave(w); // utterance contains it
    // delete_features(extra_feats); // extra features not needed
    // TODO: delete_voice
    // delete_voice(voice); // keep voice for multiple calls to synth_audio_basic


    wasm_alloc_shrink();

    return o;
}
