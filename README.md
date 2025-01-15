## Zig: cosa, come e perche

> [!NOTE]
> Contenuto in Italiano 🇮🇹

[Evento](https://www.meetup.com/coding-bunker/events/305132937/) | [Slides](https://docs.google.com/presentation/d/1y_JUGrq0Ty0m3w7ek9QgpoZWM4o7ddgVe39tWQmyioY/edit?usp=sharing)

Questo progetto usa [Zig 0.13](https://ziglang.org/download/#release-0\.13\.0)

### Eseguire i tests

Per vedere in azione il codice mostrato durante il talk:

```shell
zig build test
```

```shell
zig test src/syntax.zig
zig test src/comptime.zig
```

E' possibile (compilare ed) eseguire tests in isolamento aggiungendo il parametro `--test-filter=<test-pattern`, esempio:


```shell
zig build test --  "defer"
```

ooppure:


```shell
zig test syntax.zig --test-filter=defer
```

### Eseguire la build del progetto

```shell
zig build
```
