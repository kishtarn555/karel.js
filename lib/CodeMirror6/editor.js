import {EditorView, basicSetup} from "codemirror"
import {indentWithTab} from "@codemirror/commands"


let editor = new EditorView({
  extensions: [basicSetup, javascript()],
  parent: document.body
})