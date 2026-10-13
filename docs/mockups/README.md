# Mockup source files

Each `*.dc.html` file is one 390×844 phone screen from the approved Zyppi mockup (live, clickable canvas: https://claude.ai/artifact/BYGQkySYxNKCvX9kQvRbnM — private to the owner).

They are design references, not code to port line by line:
- Layout and styles are in plain inline CSS plus a small `<style>` block in `<helmet>` — read them for spacing, sizes and hierarchy.
- Colors and fonts are summarised in `../design-tokens.md`; use the tokens, not the hex values here.
- `<a href="X.dc.html">` links show navigation between screens; map them to the routes in `../PLAN.md` §3.
- Text in `[brackets]` is placeholder data to come from the backend.
- Icons are inline Lucide-style SVG outlines.

| File | Screen |
| --- | --- |
| Onboarding.dc.html | 01 Onboarding |
| Login.dc.html | 02 Login |
| Otp.dc.html | 03 OTP verify |
| Location.dc.html | 04 Location setup |
| Main.dc.html | 05 Home |
| Category.dc.html | 06 Category listing |
| Product.dc.html | 07 Product detail |
| Search.dc.html | 08 Search |
| Cart.dc.html | 09 Cart |
| Checkout.dc.html | 10 Checkout |
| Placed.dc.html | 11 Order placed |
| Tracking.dc.html | 12 Order tracking |
| Orders.dc.html | 13 Orders history |
| Profile.dc.html | 14 Profile |
