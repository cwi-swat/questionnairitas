module lang::ql::ide::Build

import lang::ql::util::Implode;
import lang::ql::gen::Generate;
import util::IDE;
import ParseTree;
import Message;
import IO;


private loc generated_form = |project://QL-R-komsiyski/src/form/FormGUI.java|;


public Contribution getQLBuilder() 
  = builder(set[Message] (Tree input) {
  	 writeFile(generated_form, generate(implode(input)));
	 return {};
  });
   