/// ============================================================================
/// Internal shared visual metrics/constants
/// ============================================================================
///
/// These values are intentionally internal-only and are not part of the public
/// package API. They centralize design-tuning knobs that are reused across
/// multiple renderers so visual adjustments stay consistent.
///
/// Current shared metrics:
/// - `head-size`        Arrow head size used by connectors / sequence arrows
/// - `stroke-thin`      Thin border / frame stroke
/// - `stroke-normal`    Default border / line stroke
/// - `activation-width` Default sequence activation bar width
/// - `state-min-size`   Default minimum state node size
/// - `lane-track-stroke`Baseline stroke for lane guide lines
#let metrics = (
  head-size: 0.6em,
  stroke-thin: 0.5pt,
  stroke-normal: 0.8pt,
  activation-width: 0.8em,
  state-min-size: 4.4em,
  lane-track-stroke: 1pt,
)
