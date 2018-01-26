%token <int> INT
%token LEFT_PAREN
%token RIGHT_PAREN
%token PLUS
%token EOF

%start <int> expr
%%

expr:
  | EOF { 0 }
  | a = addition { a }
  ;

addition:
  | LEFT_PAREN; PLUS; a = INT; b = INT; RIGHT_PAREN
    { a + b }
  ;
