---
title: Reading
layout: page
---

## 📊 我的实时阅读统计

<iframe id="reading-stats-iframe" src="https://v.ptbsare.org:33888/stats/ptbsare" style="width: 100%; border: none;"></iframe>

<script>
  window.addEventListener('message', function(event) {
    // For security, check the origin of the message
    if (event.origin !== 'https://v.ptbsare.org:33888') {
      return;
    }

    if (event.data.frameHeight) {
      var iframe = document.getElementById('reading-stats-iframe');
      iframe.style.height = event.data.frameHeight + 'px';
    }
  }, false);
</script>