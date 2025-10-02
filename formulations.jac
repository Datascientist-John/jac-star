"""Product Formulation Constraint Solver"""
import random;
import from byllm.llm { Model }

# Initialize global LLM model
glob llm = Model(model_name="gemini/gemini-2.5-flash", verbose=False);

""" 
Analyze the base formulation and the new constraint. 
Output the precise substitution required 
(e.g., 'Replace 10g Salt with 8g Potassium Chloride'). 
"""
def suggest_substitution(base_formula: str, new_constraint: str) -> str by llm();

walker FormulationProject {
    has project_name: str;

    can start with `root entry;
    can apply_constraint with formulation_step entry;
}

node formulation_step {
    has base_formula: str;      # Full list of ingredients and percentages
    has new_constraint: str;    # The rule to be satisfied (e.g., "Reduce sugar by 30%")
    has target_attribute: str;  # The attribute to protect (e.g., "Texture and mouthfeel")
}

# Run in CLI mode (not in cloud)
with entry:__main__ {
    root spawn FormulationProject("Vegan Cheese Sauce v3")
    spawn formulation_step("Cashews 50g, Nutritional Yeast 20g, Salt 10g", 
                                  "Reduce salt by 50%", 
                                  "Maintain creamy texture");

    root spawn FormulationProject("Low-Sodium Soup Base")
    spawn formulation_step("Water 500ml, Salt 20g, Onion Powder 15g", 
                                  "Replace salt with potassium chloride", 
                                  "Preserve flavor balance");
}

# ------------------------------
# Implementations
# ------------------------------
impl FormulationProject.start {
    print("Starting formulation project: " + self.project_name);
    if [root --> (`?formulation_step)] {
        visit [root --> (`?formulation_step)];
    }
}

impl FormulationProject.apply_constraint {
    print("Applying new constraint: " + here.new_constraint);

    # default fallback if LLM isn't available
    result = "FALLBACK: Replace 10g Salt with 8g Potassium Chloride (KCl)";

    # safer: only call the LLM-backed function if the global llm exists
    if llm != None {
        result = suggest_substitution(here.base_formula, here.new_constraint);
    } else {
        print("LLM not available, using fallback.");
    }

    print("Suggested substitution: " + result);
    disengage;
}