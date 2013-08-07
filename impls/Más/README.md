Más implementation of QL for LWC2013
====================================

This is the Más implementation of the Questionnaire Language (QL) for the Language Workbench Challenge 2013.

This implementation is partial in the following senses:
 - Since Más is non-open source, I can't actually share the actual language implementation, just its semantics in terms of code generation.
 - The code generator (i.e., language's semantics) is unfinished (as well as largely untested) and a lot of funtionality is missing.
 - It doesn't implement the QLS (Styling language).


## Dependencies

This implementation depends on the following:
 - Eclipse 4.2+ with Xtend 2.4.2+ (and thus EMF 2.9+)
 - (optional) a recent ANT

Dependencies on Más itself and other plugins have been removed at the expense of some extra, hand-crafted code.


## The moving parts

What follows is a description of the moving parts of this implementation.

### Abstract syntax

Since Más' models are edited projectively, some serialization format is required instead of a concrete, textual format: JSON is used.
The file ```models/QL_example.json``` contains the serialization of the QL (instance) example given in the LWC2013 assignment [http://www.languageworkbenches.net/images/5/53/Ql.pdf].

EMF is used to provide an abstract syntax for QL instances:
 - ```models/meta/QL.ecore``` is the Ecore meta model for QL which is transformed from the abstract syntax part of the actual language definition in Más
 	(the latter is provided as a screenshot).
 - ```models/meta/QL.genmodel``` is the associated EMF GenModel from which the EMF Java classes are generated into ```src-gen```.
 	Run ```launch configs/QL-Más build-ecore.xml.launch``` (if you have installed the ANT plugin in Eclipse) to trigger this generation.
 - ```src/com.mas.lwc2013.Unmarshaller``` unmarshalls the model JSON into abstract syntax form, i.e.: an EMF model that is an instance of the QL Ecore meta model.
	This unmarshaller is specific to the meta model: Más itself has a generic one, but that's not open source.

### The generator

The class ```src/com.mas.lwc2013.QLWebGenerator``` is the entry point for the actual HTML generation.
This class then delegates to ```JavascriptGenerator``` for generation of JavaScript code.
Instances of ```IdMapper``` are used to keep a mapping from elements in the QL instance to generated IDs of HTML elements which are referred from JavaScript code.
Several Xtension classes are used to compute derived properties on elements in the QL instance.

### The glue

The main class ```src/com.mas.lwc2013.RunGeneration``` unmarshalls ```models/QL_example.json``` as an EMF model,
passes that to the generator and saves the resulting HTML (which includes the required JavaScript code inline) as ```web/QL_example.html```.
Run ```launch configs/run configuration.launch``` to run the main class.

