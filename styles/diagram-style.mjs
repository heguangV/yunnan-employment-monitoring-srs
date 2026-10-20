// Shared course-monochrome-v1 diagram theme. Keep AGENTS.md as the visual contract.
export const theme = Object.freeze({
  id: 'course-monochrome-v1',
  font: 'Times New Roman, SimSun',
  nodeFont: 17,
  labelFont: 14,
  cardinalFont: 13,
  nodeStroke: 1.4,
  edgeStroke: 1.5,
  dividerStroke: 1.2,
  radius: 10,
  background: '#ffffff',
  text: '#111111',
  line: '#222222',
});
export const graphDefaults = `graph [bgcolor="#ffffff", fontname="SimSun", fontsize=17, pad=0.35, nodesep=0.5, ranksep=0.8, splines=ortho, forcelabels=true, overlap=false, outputorder=edgesfirst];
node [fontname="SimSun", fontsize=17, color="#222222", fontcolor="#111111", fillcolor="#ffffff", style=filled, penwidth=1.4, margin="0.13,0.09"];
edge [fontname="SimSun", fontsize=14, labelfontname="SimSun", labelfontsize=13, color="#222222", fontcolor="#111111", penwidth=1.5, arrowsize=0.7, labeldistance=1.6, labelangle=25];`;
