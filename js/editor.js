import { basicSetup } from "codemirror"
import { EditorView, keymap } from "@codemirror/view"
import { undo, redo, indentWithTab } from "@codemirror/commands"


import {EditorState} from "@codemirror/state"


let startState = EditorState.create({
    doc: "The document\nis\nshared",
    extensions: [
      history(),
      drawSelection(),
      lineNumbers(),
      keymap.of([
        ...defaultKeymap,
        ...historyKeymap,
      ])
    ]
  })

  let otherState = EditorState.create({
    doc: startState.doc,
    extensions: [
      drawSelection(),
      lineNumbers(),
      keymap.of([
        ...defaultKeymap,
        {key: "Mod-z", run: () => undo(mainView)},
        {key: "Mod-y", mac: "Mod-Shift-z", run: () => redo(mainView)}
      ])
    ]
  })



let editor = new EditorView({
    doc:"iniciar-programa\n    inicia-ejecucion\n        { TODO poner codigo aqui }\n        apagate;\n    termina-ejecucion\nfinalizar-programa",
    extensions: [
        basicSetup,
        keymap.of([indentWithTab]),
    ],
    parent: document.querySelector("#splitter-left-top-pane")
});