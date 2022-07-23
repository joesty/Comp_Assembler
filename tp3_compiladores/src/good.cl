class A {
  number: Int <- 326 + 987;
  word: String <- "Abacate";
  wordtwo: String <- "com Limao";
};

Class BB__ inherits A {
  sentence: String <- word.concat(wordtwo);
};
