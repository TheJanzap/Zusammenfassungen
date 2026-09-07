#import "../template_zusammenf.typ": colors
#import "@preview/cetz:0.5.2": angle, canvas, draw
#import "@preview/cetz-plot:0.1.4": plot

// Icon for the "Construct" button on the TI n-spire
#let tr-constructs-button = box(
  stroke: 0.1em,
  inset: (x: 0.2em),
  outset: (y: 0.25em, bottom: 0.55em),
  radius: 0.25em,
  baseline: -0.2em,
  $script(abs(ballot) cases(ballot, ballot))$,
)

#let label(pos, anchor, body) = draw.content(pos, anchor: anchor, padding: 0.2, body)

// Creates a unit plot
#let unit-plot() = {
  import draw: *
  let text-size = 0.8em

  set-style(stroke: (paint: gray, thickness: 0.05em))
  line((-1.5, 0), (1.5, 0), mark: (end: ">"))
  content((), padding: 0.1em, text(size: text-size)[$x$], anchor: "west")

  line((0, -1.5), (0, 1.5), mark: (end: ">"))
  content((), padding: 0.1em, text(size: text-size)[$y$], anchor: "south")
  content((-0.05, -0.05), text(size: 0.8em)[0], anchor: "north-east")

  // Axis markings
  for v in (1, -1) {
    content((v + 0.1, -0.1), text(size: text-size)[#v], anchor: "north")
    content((-0.05, v + 0.1), text(size: text-size)[#v], anchor: "east")
  }
}

#let trigo() = {
  canvas(length: 2.3em, {
    import draw: *
    set-style(stroke: (thickness: 0.1em))

    line((0, 0), (2, 0), name: "Ankathete")
    label("Ankathete", "north", $a$)

    line((2, 0), (2, 2), name: "Gegenkathete")
    label("Gegenkathete", "west", $g$)

    line((0, 0), (2, 2), name: "Hypothenuse")
    label("Hypothenuse", "south", $h$)

    set-style(stroke: (paint: black))
    angle.angle("Ankathete.start", "Ankathete.end", "Hypothenuse.end", radius: 50%, label: $alpha$)

    angle.angle("Gegenkathete.start", "Gegenkathete.end", "Ankathete.start", label: $dot$)
  })
}

#let strahlensatz() = {
  canvas(length: 2em, {
    import draw: *

    set-style(stroke: (thickness: 0.1em))

    // Interpolate a line between the start and end
    let lerp(start, end, t) = (
      start.at(0) * (1 - t) + end.at(0) * t,
      start.at(1) * (1 - t) + end.at(1) * t,
    )

    let S = (0, 0)
    let r1 = (5, 2)
    let r2 = (5, -1)
    let p = 0.4
    let q = 0.75
    let Ap = lerp(S, r1, p)
    let A = lerp(S, r1, q)
    let Bp = lerp(S, r2, p)
    let B = lerp(S, r2, q)

    // Lines
    line(S, A)
    line(S, B)
    line(lerp(S, r1, p), lerp(S, r2, p))
    line(lerp(S, r1, q), lerp(S, r2, q))

    // Points
    fill(black)
    for pt in (S, A, Ap, B, Bp) { circle(pt, radius: 0.05) }

    label(S, "east", $S$)
    label(A, "south", $A$)
    label(Ap, "south", $A'$)
    label(B, "north", $B$)
    label(Bp, "north", $B'$)
  })
}

#let angle-position-auf-kreis = 30deg
#let cos-angle = calc.cos(angle-position-auf-kreis)
#let sin-angle = calc.sin(angle-position-auf-kreis)
#let angle-str = calc.round(angle-position-auf-kreis.deg())
#let length-position-auf-kreis = 4.6em
#let text-size-position-auf-kreis = 1.2em

#let position-auf-kreis-sin-cos() = {
  canvas(length: length-position-auf-kreis, {
    import draw: *

    let angle = angle-position-auf-kreis
    let text-size = text-size-position-auf-kreis

    set-style(stroke: (thickness: 0.15em), mark: (length: 0.7em, width: 0.4em))
    unit-plot()

    circle((0, 0), radius: 1)

    arc((0, 1), start: 90deg, stop: 90deg - angle, stroke: (paint: colors.dunkelblau, thickness: 0.1em))
    circle((sin-angle, cos-angle), radius: 0.05, fill: colors.hellblau, stroke: white + 0.1em, name: "1")
    label("1", "west", text(size: text-size, $vec(+sin(#angle-str°), +cos(#angle-str°))$))

    arc((0, 1), start: 90deg, stop: 90deg + angle, stroke: (paint: colors.orange, thickness: 0.1em))
    circle((-sin-angle, cos-angle), radius: 0.05, fill: colors.gelb, stroke: white + 0.1em, name: "2")
    label("2", "east", text(size: text-size, $vec(-sin(#angle-str°), +cos(#angle-str°))$))

    arc((0, -1), start: 270deg, stop: 270deg - angle, stroke: (paint: colors.orange, thickness: 0.1em))
    circle((-sin-angle, -cos-angle), radius: 0.05, fill: colors.gelb, stroke: white + 0.1em, name: "3")
    label("3", "east", text(size: text-size, $vec(-sin(#angle-str°), -cos(#angle-str°))$))

    arc((0, -1), start: 270deg, stop: 270deg + angle, stroke: (paint: colors.dunkelblau, thickness: 0.1em))
    circle((sin-angle, -cos-angle), radius: 0.05, fill: colors.hellblau, stroke: white + 0.1em, name: "4")
    label("4", "west", text(size: text-size, $vec(+sin(#angle-str°), -cos(#angle-str°))$))
  })
}


#let position-auf-kreis-cos-sin() = {
  canvas(length: length-position-auf-kreis, {
    import draw: *

    let angle = angle-position-auf-kreis
    let text-size = text-size-position-auf-kreis

    set-style(stroke: (thickness: 0.15em), mark: (length: 0.7em, width: 0.4em))
    unit-plot()

    circle((0, 0), radius: 1)

    arc((1, 0), start: 0deg, stop: angle, stroke: (paint: colors.dunkelblau, thickness: 0.1em))
    circle((cos-angle, sin-angle), radius: 0.05, fill: colors.hellblau, stroke: white + 0.1em, name: "1")
    label("1", "south", text(size: text-size, $vec(+cos(#angle-str°), +sin(#angle-str°))$))

    arc((-1, 0), start: 180deg, stop: 180deg - angle, stroke: (paint: colors.dunkelblau, thickness: 0.1em))
    circle((-cos-angle, sin-angle), radius: 0.05, fill: colors.hellblau, stroke: white + 0.1em, name: "2")
    label("2", "south", text(size: text-size, $vec(-cos(#angle-str°), +sin(#angle-str°))$))

    arc((-1, 0), start: 180deg, stop: 180deg + angle, stroke: (paint: colors.orange, thickness: 0.1em))
    circle((-cos-angle, -sin-angle), radius: 0.05, fill: colors.gelb, stroke: white + 0.1em, name: "3")
    label("3", "north", text(size: text-size, $vec(-cos(#angle-str°), -sin(#angle-str°))$))

    arc((1, 0), start: 360deg, stop: 360deg - angle, stroke: (paint: colors.orange, thickness: 0.1em))
    circle((cos-angle, -sin-angle), radius: 0.05, fill: colors.gelb, stroke: white + 0.1em, name: "4")
    label("4", "north", text(size: text-size, $vec(+cos(#angle-str°), -sin(#angle-str°))$))
  })
}



/*#let position-auf-kreis-point(name, position, arc-center, start, stop, color, anchor, label-text) = {
  draw.arc(
    arc-center,
    start: start,
    stop: stop,
    stroke: (paint: color, thickness: 0.1em),
  )
  draw.circle(
    position,
    radius: 0.05,
    fill: if color == colors.dunkelblau { colors.hellblau } else { colors.gelb },
    stroke: white + 0.1em,
    name: name,
  )
  label(name, anchor, text(size: text-size-position-auf-kreis, label-text))
}

#let position-auf-kreis-cos-sin() = {
  canvas(length: length-position-auf-kreis, {
    import draw: *

    let angle = angle-position-auf-kreis

    set-style(
      stroke: (thickness: 0.15em),
      mark: (length: 0.7em, width: 0.4em),
    )

    unit-plot()
    circle((0, 0), radius: 1)

    position-auf-kreis-point(
      "1", (cos-angle,  sin-angle), (1, 0),   0deg,       angle,
      colors.dunkelblau, "south",
      $vec(+cos(#angle-str°), +sin(#angle-str°))$,
    )

    position-auf-kreis-point(
      "2", (-cos-angle,  sin-angle), (-1, 0), 180deg, 180deg-angle,
      colors.dunkelblau, "south",
      $vec(-cos(#angle-str°), +sin(#angle-str°))$,
    )

    position-auf-kreis-point(
      "3", (-cos-angle, -sin-angle), (-1, 0), 180deg, 180deg+angle,
      colors.orange, "north",
      $vec(-cos(#angle-str°), -sin(#angle-str°))$,
    )

    position-auf-kreis-point(
      "4", (cos-angle, -sin-angle), ( 1, 0), 360deg, 360deg-angle,
      colors.orange, "north",
      $vec(+cos(#angle-str°), -sin(#angle-str°))$,
    )
  })
}

#let position-auf-kreis-sin-cos() = {
  canvas(length: length-position-auf-kreis, {
    import draw: *

    let angle = angle-position-auf-kreis

    set-style(
      stroke: (thickness: 0.15em),
      mark: (length: 0.7em, width: 0.4em),
    )

    unit-plot()
    circle((0, 0), radius: 1)

    position-auf-kreis-point(
      "1", (sin-angle,  cos-angle), (0, 1),   0deg,       angle,
      colors.dunkelblau, "south",
      $vec(+cos(#angle-str°), +sin(#angle-str°))$,
    )

    position-auf-kreis-point(
      "2", (-sin-angle,  cos-angle), (-1, 0), 180deg, 180deg-angle,
      colors.dunkelblau, "south",
      $vec(-cos(#angle-str°), +sin(#angle-str°))$,
    )

    position-auf-kreis-point(
      "3", (-sin-angle, -cos-angle), (-1, 0), 180deg, 180deg+angle,
      colors.orange, "north",
      $vec(-cos(#angle-str°), -sin(#angle-str°))$,
    )

    position-auf-kreis-point(
      "4", (sin-angle, -cos-angle), ( 1, 0), 360deg, 360deg-angle,
      colors.orange, "north",
      $vec(+cos(#angle-str°), -sin(#angle-str°))$,
    )
  })
}*/

#let bewegung-auf-kreis() = {
  canvas(length: 5.5em, {
    import draw: *

    set-style(stroke: (thickness: 0.2em), mark: (length: 0.8em, width: 0.5em))
    unit-plot()

    // --- Unterer Halbkreis: t = π … 2π ---
    arc(
      (1, 0),
      start: 0deg,
      stop: -180deg,
      radius: 1,
      stroke: (paint: colors.hellblau, thickness: 0.1em, dash: "dashed"),
    )

    // --- Oberer Halbkreis: t = 0 … π (durchgezogen, blau) ---
    arc(
      (1, 0),
      start: 0deg,
      stop: 177deg,
      radius: 1,
      stroke: (paint: colors.hellblau),
      mark: (end: ">", fill: colors.hellblau),
    )

    // --- Verschiebungsvektor Δr ---
    line(
      (1, 0),
      (-1 + 0.05, 0),
      mark: (end: ">", fill: colors.orange),
      stroke: (paint: colors.orange),
    )
    content(
      (0, 0.05),
      text(fill: colors.orange, weight: "bold")[$Delta bold(r) = vec(-2, 0), quad abs(Delta bold(r)) = 2$],
      anchor: "south",
    )

    // --- Startpunkt t = 0 ---
    circle((1, 0), radius: 0.05, fill: colors.dunkelblau, stroke: white + 0.2em)
    content(
      (1 + 0.05, 0.3),
      text(fill: colors.dunkelblau, weight: "bold")[$t = 0$ \ $(1,0)$],
      anchor: "west",
    )

    // --- Endpunkt t = π ---
    circle((-1, 0), radius: 0.05, fill: colors.rot, stroke: white + 0.2em)
    content(
      (-1 - 0.05, 0.3),
      text(fill: colors.rot, weight: "bold")[$t = pi$ \ $(-1,0)$],
      anchor: "east",
    )
  })
}

#let momentangeschwindigkeit-kreis() = {
  canvas(length: 3.7em, {
    import draw: *
    set-style(stroke: (thickness: 0.15em), mark: (length: 0.7em, width: 0.4em))
    unit-plot()

    circle((0, 0), radius: 1)
    arc(
      (1, 0),
      start: 0deg,
      stop: 90deg,
      stroke: (paint: colors.hellblau, thickness: 0.2em),
    )
    line(
      (0, 1),
      (-0.75, 1),
      stroke: (paint: colors.rot, thickness: 0.2em),
      mark: (end: ">", fill: colors.rot),
    )
    circle((0, 1), radius: 0.08, fill: colors.rot, stroke: white + 0.15em)
  })
}

#let kreis-beschleunigung() = {
  canvas(length: 5.1em, {
    import draw: *

    set-style(stroke: (thickness: 0.15em), mark: (length: 0.7em, width: 0.4em))
    unit-plot()

    circle((0, 0), radius: 1)
    line(
      (1, 0),
      (1, 1),
      stroke: (paint: colors.dunkelblau, thickness: 0.2em),
      mark: (end: ">", size: 0.25, fill: colors.dunkelblau),
    )
    line(
      (1, 0),
      (0, 0),
      stroke: (paint: colors.rot, thickness: 0.2em),
      mark: (end: ">", size: 0.25, fill: colors.rot),
    )
    circle((1, 0), radius: 0.05, fill: black)

    label((1, 0.5), "west", text(size: 0.8em, fill: colors.dunkelblau)[$v(t)$])
    label((0.5, 0), "south", text(size: 0.8em, fill: colors.rot)[$a(t)$])
  })
}

#let schiefer-wurf() = {
  canvas(length: 3.4em, {
    import draw: *
    let text-size = 0.8em

    set-style(stroke: (thickness: 0.1em), mark: (length: 0.7em, width: 0.4em))
    line((-0.5, 0), (3, 0), mark: (end: ">"))
    content((), padding: 0.1em, text(size: text-size)[$x$], anchor: "west")

    line((0, -0.5), (0, 2), mark: (end: ">"))
    content((), padding: 0.1em, text(size: text-size)[$y$], anchor: "south")
    content((-0.05, -0.05), text(size: 0.8em)[0], anchor: "north-east")

    label((0, 1), "east", text(size: text-size, [$y_0$]))

    line((0, 1), (1.5, 1), name: "diag", stroke: (paint: gray, dash: "dashed"))
    label((1, 2), "north", text(size: text-size)[$v_0$])
    line((0, 1), (1, 2), name: "curve", mark: (end: ">"))
    circle((0, 1), radius: 0.05, fill: gray)

    angle.angle("diag.start", "diag.end", "curve.end", label: $alpha$, radius: 50%)
  })
}

#let waagrechter-wurf(scaling: 1) = {
  canvas({
    import draw: *
    import calc: pow

    let g = -9.81
    let v_0 = 10
    let h = 5

    set-style(
      stroke: (thickness: 0.1em),
      mark: (length: 0.7em, width: 0.4em),
      axes: (tick: (stroke: 0.1em, length: 1.3em)),
    )

    scale(scaling)

    plot.plot(
      size: (7, 6),
      y-label: $h$,
      axis-style: "left",
      {
        plot.add(domain: (0, 10.1), x => 1 / 2 * g * pow(x / v_0, 2) + h)
      },
    )
  })
}

#let kreiskraft(scaling: 1) = {
  canvas(length: 1cm * scaling, {
    import draw: *

    let R = 1
    let phi = 35deg

    // Helper point on the circle
    let P = (
      x: R * calc.cos(phi),
      y: R * calc.sin(phi),
    )

    // Unit vectors
    let ur = (
      x: calc.cos(phi),
      y: calc.sin(phi),
    )

    let ut = (
      x: -calc.sin(phi),
      y: calc.cos(phi),
    )

    set-style(mark: (length: 1em, width: 0.4em))

    unit-plot()

    // Background circle
    circle((0, 0))

    set-style(stroke: (black + 0.1em))

    // Radius
    line((0, 0), P, mark: (end: ">", fill: black), name: "r")

    // Velocity (tangent)
    let V = (
      x: P.x + ut.x * 0.7,
      y: P.y + ut.y * 0.7,
    )

    line(P, V, mark: (end: ">", fill: black), name: "v")

    label("v", "base-east", $v(t) = r dot dot(#sym.phi) (t)$)

    // Radial acceleration (toward center)
    let AZ = (
      x: P.x - ur.x * 0.4,
      y: P.y - ur.y * 0.4,
    )
    line(P, AZ, stroke: red, mark: (end: ">", fill: red), name: "a_Z")
    label("a_Z", "west", text(fill: red)[$a_Z(t) parallel r(t)$])

    // Tangential acceleration
    let AT = (
      x: P.x + ut.x * 0.4,
      y: P.y + ut.y * 0.4,
    )
    line(P, AT, stroke: red, mark: (end: ">", fill: red), name: "a_T")
    label("a_T", "mid-west", text(fill: red)[$a_T (t) parallel v(t)$])

    // Point on circle
    circle(P, radius: 0.03, fill: black, name: "P")

    // Radius label
    label("r", "mid-east", $r(t)$)

    // Angle arc
    angle.angle("r.start", (0.5, 0), "r.end", name: "angle")

    content((0.32, 0.1), $#sym.phi (t)$)
  })
}
