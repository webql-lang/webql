import webql/loader/load_json

type LoaderMode {
  Json
}

pub opaque type Loader {
  Loader(mode: LoaderMode)
}

/// Creates a new loader instance.
pub fn new() {
  Loader(mode: Json)
}

/// Grabs a loader instance and a document and converts it into a schema.
pub fn load(loader: Loader, document: String) {
  case loader.mode {
    Json -> load_json.load(document)
  }
}
