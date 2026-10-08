# App architecture

[Bahasa Indonesia](../id/arsitektur.md)

The app is written in Flutter for Android. Every model runs on the phone: the ingredient detector and OCR through
ONNX Runtime, the language model through llama.cpp's `llama-server` started as a local process, and Whisper through
sherpa-onnx.

## Code layout

```
lib/
  main.dart            entry point; opening animation, model setup, nickname, then home
  app_state.dart       app state: settings, models, sessions, history, photo preparation for the models
  core/
    pipeline.dart      one turn: photo, markers, request parsing, answer selection
    grounding.dart     markers: duplicate removal, numbering, counting units
    recipes.dart       recipe book, ranking, request rules
    vocab.dart         ingredient and package brand vocabulary
    history.dart       SQLite history with size limits
    generated.dart     shared data from the MEIRA-Before repository (do not edit by hand)
  vision/
    detector.dart      D-FINE ingredient detector (ONNX)
    ocr.dart           PP-OCRv5 package OCR (ONNX)
    ort.dart           ONNX Runtime wrapper over FFI
    vision.dart        isolate that runs the detector and OCR
  llm/
    memory.dart        conversation memory with summaries
    retriever.dart     BM25 recipe search
    knowledge.dart     BM25 kitchen-note search
    chain.dart         answer chain with automatic continuation
    guardrails.dart    input and output checks
  runtime/
    llama.dart         llama-server manager and HTTP client
    speech.dart        Whisper and the phone's TTS
    models.dart        model list, downloads, and installation from files
  ui/                  opening, home, chat screen, recipes, cooking mode, history, dataset, settings
assets/models/         detector and OCR shipped inside the APK
```

## Screens

| Screen | Contents |
|---|---|
| Opening | the green screen opens a small round hole, a cooking pan pops up inside it, and the hole widens until the screen is white while the models load |
| Nickname | the pan fades out and a green header slides down with the greeting; asked once and stored only on the phone. After the name is entered, the white sheet slides up into the home screen |
| Kitchen (home) | greeting, ask field, camera and gallery buttons, filterable recipe book |
| Chat | marked photo, recipe cards, answers, suggested questions, ask field; no bottom bar, with a back button |
| Recipe | ingredients with availability, steps, cooking mode with timers |
| History, Dataset, Settings | tabs in the bottom bar |

![App screens](../img/tampilan.jpg)

## One conversation turn

1. **Markers.** The photo is resized to 640 x 640 pixels and checked by the detector in its own isolate. Boxes
   above the threshold become numbered markers.
2. **Packages.** OCR reads package text; lines naming a known ingredient or brand become markers.
3. **Extra photos.** The add-photo button in the chat screen adds ingredients from another photo without replacing
   the main one.
4. **Input guard.** `Guardrails.checkInput` refuses prompt injection, harmful requests, medical questions, and
   off-topic messages. Follow-ups such as "how do I make it" always pass.
5. **Request parsing.** `ruleIntent` picks the request type and its slots.
6. **Answer.** Recipes come from the recipe book, kitchen questions from the kitchen notes, and anything else is
   answered by Qwen3.5-0.8B with context and then checked. A note is used only when it mentions the ingredient being
   asked about. Questions about an ingredient's properties, such as how green and red apples differ, are treated as
   conversation rather than recipe requests; when no note matches, the model answers and a cut-off last sentence is
   dropped. Ingredients typed in a message are acknowledged at the start of the answer, and the first answer starts with the user's nickname.
7. **Memory.** Older turns are summarized once they pass 700 tokens.

## Motion

Animations are short and soft so the app feels calm: the opening sequence, fading tab switches, recipe rows that
slide in one after another, cards that shrink slightly when pressed, numbered markers that pop in, a light sweep over
the photo while it is being read, and answers that appear word by word. The opening is driven by a clock that caps
each frame step, so a slow first launch pauses the motion instead of skipping it.

## Resources

- The detector and OCR load once in the isolate when the first photo is processed.
- `llama-server` can be released when the app sits in the background for over three minutes.
- Whisper loads when the microphone is used and is released after two idle minutes.
- History is capped at 200 sessions and 300 MB of photos; the oldest go first.

## Data and privacy

All data stays in the app folder: history, photos, settings, nickname, and models. The internet is only used to
download models during setup, and that step can be skipped by installing models from files.
