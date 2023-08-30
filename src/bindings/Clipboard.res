@scope(("navigator", "clipboard")) external writeText: string => promise<bool> = "writeText"
