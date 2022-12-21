import { basicSetup } from "codemirror"
import { EditorView, keymap } from "@codemirror/view"
import { indentWithTab } from "@codemirror/commands"


let editor = new EditorView({
    extensions: [
        basicSetup,
        keymap.of([indentWithTab]),
    ],
    parent: document.body
});