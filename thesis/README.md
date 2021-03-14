# Thesis

Folder with the LaTex source files for the thesis.

Use scripts/generatePdf.sh to create the PDF.

## Generate diagrams

The diagrams folder contains plantuml files for various diagrams.
 
Install this tools to generate the diagrams:

```bash
sudo apt-get install plantuml graphviz
```

You can now generate the diagrams by running `make diagrams` in the `ex_app` folder.
This will generate png from all `*.puml` files in `thesis` and store them in `thesis/diagrams`. 

