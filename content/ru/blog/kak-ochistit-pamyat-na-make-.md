---
title: "Как «очистить» память на Маке "
date: "2011-12-29T11:34:00"
topics:
  - "mac"
slug: "61-kak-ochistit-pamyat-na-make-"
feed: false
---
«Очистить» память на Маке очень просто. Надо открыть терминал, набрать команду `purge` и нажать Enter. Всё. Никакие дополнительные программы за $0.99 из App Store для этого не нужны.

Для любопытных поясню, как это работает и для чего это нужно. Если вы откроете программу «Мониторинг системы», то увидите такую картину:

![sysmon](/ru/images/sysmon.png)

Обратите внимание на пункт «Неактивная память» (выделен синим цветом). Эта память, которая была занята каким-то ранее запущеным приложением. Если вы запустите это приложение снова, то, теоретически, оно запустится быстрее, если связанная с ним неактивная память не была занята другими программами. В реальной жизни я не вижу в этом особых преимуществ.

Напротив, если у вас не хватает свободной памяти и при этом есть куча неактивной, то система начинает активно использовать своп, а это приводит к конкретным тормозам. Поэтому я регулярно очищаю память упомянутой выше командой.

Чтобы не запускать каждый раз терминал, я сделал [расширение](http://cl.ly/3i0c363F0Y0z121T3g3x) для [Alfred](http://www.alfredapp.com/), которое делает всё за меня.

**Обновлено:** Судя по всему, для использования утилиты `purge` у вас должен быть установлен Xcode. В качестве альтернативы в интернетах предлагают установить [OnyX](http://www.titanium.free.fr/download.php), но этот способ я не проверял.
