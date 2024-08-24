# llm_server.dart
A dart library to embed the llama.cpp server into flutter apps.
rwkv.cpp support is planned.


The llama.cpp repository was added as a subtree because dart pub doesn't support submodules.

The command used was:
```
git subtree add --prefix src/llama.cpp https://github.com/ggerganov/llama.cpp master --squash
```
