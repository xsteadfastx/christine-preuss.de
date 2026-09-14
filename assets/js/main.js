// CHRISTINE PREUSS — scrollspy nav + impressum dialog (self-hosted, no deps)

(function () {
  "use strict";

  // Scrollspy: highlight the nav item of the section currently in view.
  var links = document.querySelectorAll("#nav .item");
  var map = {};
  links.forEach(function (l) {
    var m = (l.getAttribute("href") || "").match(/#(\w+)$/);
    if (m) map[m[1]] = l;
  });
  var sections = Object.keys(map).map(function (id) { return document.getElementById(id); });

  var spy = new IntersectionObserver(function (entries) {
    entries.forEach(function (e) {
      if (!e.isIntersecting) return;
      links.forEach(function (l) { l.classList.remove("is-active"); });
      var el = map[e.target.id];
      if (el) el.classList.add("is-active");
    });
  }, { rootMargin: "-45% 0px -50% 0px", threshold: 0 });

  sections.forEach(function (s) { if (s) spy.observe(s); });

  // Compact the header once the page is scrolled (own scope: keeps the
  // captured element safe from name-collision when the minifier hoists vars).
  // Hysteresis: shrink only after 90px, grow only back below 30px — so the
  // size settles instead of jittering around a single threshold.
  (function () {
    var hdr = document.querySelector("header.site");
    if (!hdr) return;
    var SMALL = 90, BIG = 30;
    var onScroll = function () {
      var y = window.scrollY;
      var compact = hdr.classList.contains("is-scrolled");
      if (compact && y < BIG) hdr.classList.remove("is-scrolled");
      else if (!compact && y > SMALL) hdr.classList.add("is-scrolled");
    };
    window.addEventListener("scroll", onScroll, { passive: true });
    onScroll();
  })();

  // Collapsible PROJEKTE in the Inhaltsangabe
  var pt = document.getElementById("proj-toggle");
  var sublis = document.getElementById("proj-sublist");
  if (pt && sublis) {
    pt.addEventListener("click", function () {
      var open = sublis.classList.toggle("is-open");
      pt.setAttribute("aria-expanded", open ? "true" : "false");
    });
    if (sublis.hasAttribute("data-open")) {
      sublis.classList.add("is-open");
      pt.setAttribute("aria-expanded", "true");
    }
  }

  // Impressum dialog
  var dlg = document.getElementById("impressum");
  if (dlg) {
    document.querySelectorAll('a[href="#impressum"]').forEach(function (a) {
      a.addEventListener("click", function (e) {
        e.preventDefault();
        dlg.showModal();
      });
    });
    var close = dlg.querySelector(".x");
    if (close) close.addEventListener("click", function () { dlg.close(); });
    dlg.addEventListener("click", function (e) {
      if (e.target === dlg) dlg.close();
    });
  }

  // Gallery lightbox
  var lb = document.getElementById("lightbox");
  var works = [].map.call(document.querySelectorAll("figure[data-title]"), function (f) {
    return {
      webp: f.getAttribute("data-full-webp"),
      jpg: f.getAttribute("data-full-jpg"),
      title: f.getAttribute("data-title") || "",
      sub: f.getAttribute("data-sub") || ""
    };
  });
  if (lb && works.length) {
    var lbImg = lb.querySelector("#lb-img");
    var lbTitle = lb.querySelector("#lb-title");
    var lbSub = lb.querySelector("#lb-sub");
    var idx = 0;
    function show(i) {
      idx = (i + works.length) % works.length;
      var w = works[idx];
      lbImg.onerror = function () { this.onerror = null; this.src = w.jpg; };
      lbImg.src = w.webp; lbImg.alt = w.title;
      lbTitle.textContent = w.title;
      lbSub.textContent = w.sub;
    }
    [].forEach.call(document.querySelectorAll("figure[data-title]"), function (f, i) {
      f.addEventListener("click", function () { show(i); lb.showModal(); });
    });
    var c = lb.querySelector(".lb-close");
    if (c) c.addEventListener("click", function () { lb.close(); });
    var p = lb.querySelector(".lb-prev"), n = lb.querySelector(".lb-next");
    if (p) p.addEventListener("click", function () { show(idx - 1); });
    if (n) n.addEventListener("click", function () { show(idx + 1); });
    lb.addEventListener("click", function (e) { if (e.target === lb || e.target === lb.querySelector(".lb-stage")) lb.close(); });
    lb.addEventListener("keydown", function (e) {
      if (e.key === "ArrowLeft") show(idx - 1);
      if (e.key === "ArrowRight") show(idx + 1);
    });
  }
})();
