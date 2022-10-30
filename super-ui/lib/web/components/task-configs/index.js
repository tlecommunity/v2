import buildShips from './build-ships';
import dockedShips from './docked-ships';
import hallsCost from './halls-cost';
import makeHalls from './make-halls';
import pushBuildingsUp from './push-buildings-up';
import pushGlyphs from './push-glyphs';
import scuttleShips from './scuttle-ships';
import spySkills from './spy-skills';
import spyStatus from './spy-status';
import spyTrainer from './spy-trainer';
import viewLaws from './view-laws';

const taskConfigs = {
  'build-ships': buildShips,
  'docked-ships': dockedShips,
  'halls-cost': hallsCost,
  'make-halls': makeHalls,
  'push-buildings-up': pushBuildingsUp,
  'push-glyphs': pushGlyphs,
  'scuttle-ships': scuttleShips,
  'spy-skills': spySkills,
  'spy-status': spyStatus,
  'spy-trainer': spyTrainer,
  'view-laws': viewLaws,
};

export default taskConfigs;
