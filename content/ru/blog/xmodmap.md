---
title: "Как изменить значения кнопок на клавиатуре и мыши (Linux)"
date: "2007-11-07T03:02:00"
topics:
  - "linux"
  - "xmodmap"
slug: "53/xmodmap"
feed: false
---
В [прошлом посте](http://cornelius.net.ru/blog/new-keyboard) я рассказал о покупке новой клавиатуры и возникших в связи с этим проблемах. Одной из таких проблем было непривычное для меня расположение кнопок в блоке Home/End/Del/Ins/PgUp/PgDown. Поэтому мне пришлось переключиться на использование цифровой клавиатуры, на которой имеются аналогичные клавиши. Однако оказалось, что эти клавиши не работают как следует в некоторых приложениях.

Причина кроется в том, что при нажатии, например, обычного Delete генерируется сигнал `Delete` (что вполне логично), а при нажатии Delete на цифровом блоке генерируется сингал `KP_Delete` (что тоже в общем не лишено логики). Видимо именно этот префикс `KP_` и вызывает неприятности, например у меня не всегда срабатывало сочетание `Shift+KP_Insert` (сами догадаетесь, что оно должно делать).

Помогла мне замечательная утилита `xmodmap`, с помощью которой можно переопределить значения клавиш (например, чтобы `KP_Delete` работал как простой `Delete`)

<!-- more -->

`xmodmap` запускается от имени пользователя и действует в текущем сеансе X. Детальное описание её работы можно прочитать в `man xmodmap`, я лишь вкратце изложу те её возможности, которыми я воспользовался.

Для начала надо определить, какие сигналы вызываются при нажатии той или иной клавиши, а также разобраться с кодами клавиш. В этом поможет утилита `xev`. Она позволяет отслеживать все события, генерируемые клавиатурой и мышью (нажатия клавиш, нажатия кнопок мыши и даже её движение). Запускать её надо из консоли, потому что именно там будет отображаться информация о производимых вами действиях. Вот пример её вывода:

    KeyPress event, serial 31, synthetic NO, window 0x6600001,
        root 0x13b, subw 0x0, time 211379992, (-35,-32), root:(716,420),
        state 0x0, keycode 91 (keysym 0xff9f, KP_Delete), same_screen YES,
        XLookupString gives 0 bytes:
        XmbLookupString gives 0 bytes:
        XFilterEvent returns: False

Обратите внимание на `keycode` – цифровой идентификатор клавиши и `KP_Delete` – как эта клавиша интерпретируется.

Итак, первое, что я сделал – заставил работать кнопки на цифровом блоке. Для этого мне нужно, чтобы кнопка с `keycode 91` срабатывала не как `KP_Delete`, а как простой `Delete`. Для этого я воспользовался следующей командой:

    xmodmap -e "keycode 91 = Delete"

Думаю, что дополнительных пояснений тут не требуется. Аналогичную операцию я провёл и для остальных клавиш цифрового блока (Ins, Home, End, PgUp, PgDown, курсоры и Enter).

Так как я никогда не использовал цифровую клавиатуру для набора цифр, я решил полностью отключить *NumLock* (а заодно и *CapsLock*). Вот, что я для этого сделал:

    xmodmap -e "remove lock = Caps_Lock"
    xmodmap -e "remove mod2 = Num_Lock"

Теперь при нажатии NumLock сигнал `Num_Lock` вызывается, но модификатор при этом не включается.

Кстати, посмотреть текущую таблицу модификаторов можно запустив `xmodmap` без параметров.

Кроме проблем с клавиатурой я упомянал и о проблеме с мышкой – очень туго нажимается средняя кнопка (колёсико). При этом непосредственно под колёсиком расположены две “бесполезные” кнопки, которые нажимаются безо всяких проблем. Почему бы не приспособить одну из них под среднюю кнопку? Здесь мне опять помог `xmodmap`.

Для начала надо определить номера кнопок – придётся снова обратится к `xev`. Имеем: средняя кнопка – номер 2, “бесполезные” кнопки – номера 8 и 9. Затем выполняем следующую команду:

    xmodmap -e "pointer = 1 8 3 4 5 6 7 2 9"

Обратите внимание – я поменял местами цифры 2 и 8. Это значит, что восьмая кнопка будет выполнять роль второй (средней), и наоборот.

Кстати, вот так

    xmodmap -e "pointer = 3 2 1"
    
текущем сеансе X. Для удобства я вынес все указанные выше директивы в файл [~/.xmodmaprc](http://files.grove.org.ru/cornelius/.xmodmaprc) и в начале сеанса запускаю `xmodmap`, передав ему имя файла в качестве параметра:

    xmodmap /home/andrey/.xmodmaprc

Настоятельно рекомендую к прочтению `man xmodmap`, возможно вы найдёте своё применение для этой утилиты.
