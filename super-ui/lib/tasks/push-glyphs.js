import Promise from 'bluebird';
import _ from 'lodash';

import lacuna from '../lacuna';
import log from '../log';
import util from '../util';

class PushGlyphs {
  constructor(options) {
    this.options = options;

    this.glyphsPushed = 0;
  }

  getBestShip(requiredCargo, fleets) {
    // TODO: should we support an option to specifiy a type of ship
    // for pushing glyphs? Or maybe a ship name?
    // If so, that all needs to happen in here.

    return _.chain(fleets)
      .filter((fleet) => util.int(fleet.details.hold_size) >= requiredCargo)
      .sortBy((fleet) => util.int(fleet.details.speed))
      .first()
      .value();
  }

  prepareCargo(glyphs) {
    return _.map(glyphs, (glyph) => {
      return {
        type: 'glyph',
        name: glyph.name,
        quantity: glyph.quantity,
      };
    });
  }

  async handleSending(from, to, tradeId) {
    let trade = lacuna.buildings.trade;

    const glyphSummary = await trade.getGlyphSummary([tradeId]);
    if (glyphSummary.glyphs.length === 0) {
      log.info('No glyphs to push');
      return;
    }

    const ships = await trade.getTradeFleets({
      building_id: tradeId,
      target_d: to.id,
    });

    if (ships.fleets.length === 0) {
      log.error('No ships for pushing glyphs');
      return;
    }

    let total = _.sum(_.map(glyphSummary.glyphs, 'quantity'));
    let requiredCargo = total * glyphSummary.cargo_space_used_each;

    let ship = this.getBestShip(requiredCargo, ships.fleets);

    if (!ship) {
      log.error('No viable ship for pushing glyphs');
      return;
    }

    let params = {
      building_id: tradeId,
      target: { body_id: to.id },
      items: this.prepareCargo(glyphSummary.glyphs),
      fleet: {
        id: ship.id,
        quantity: 1,
        stay: 0,
      },
    };

    log.info(`Pushing ${total} glyphs`);

    const result = await trade.pushItems(params);

    let arrival = util.formatServerDate(result.fleet.date_arrives);
    let plural = util.handlePlurality(total, 'glyph');

    log.info(`${total} ${plural} landing on ${to.name} at ${arrival}`);

    this.glyphsPushed += total;
  }

  async pushGlyphs(from, to, buildings) {
    const tradeMin = await lacuna.body.findBuilding(buildings, 'Trade Ministry');

    if (!tradeMin) {
      log.error(`No Trade Ministry found on ${from.name}`);
    } else {
      return this.handleSending(from, to, tradeMin.id);
    }
  }

  validateOptions() {
    return new Promise((resolve, reject) => {
      if (!this.options.from) {
        reject('please specify a planet to push glyphs from');
      } else {
        resolve(true);
      }
    });
  }

  async run() {
    const { status } = await lacuna.empire.getStatus({});

    if (status.empire.is_isolationist == 1) {
      log.info('Your empire is an isolationist and only has one colony.');
    }

    const fromColonies = await lacuna.empire.findPlanets(this.options.from, this.options.to);
    const to = await lacuna.empire.findPlanet(this.options.to);

    if (!fromColonies.length) {
      log.info('No colonies to push glyphs from.');
    }

    await lacuna.empire.eachPlanet(
      fromColonies,
      (colony, buildings) => {
        return this.pushGlyphs(colony, to, buildings);
      },
      // Use 'force' to avoid ignoring unhappy planets. It doesn't affect sending ships.
      { force: true }
    );

    let plural = util.handlePlurality(this.glyphsPushed, 'glyph') > 1 ? 'glyphs' : 'glyph';
    log.info(
      this.glyphsPushed === 0
        ? `Didn't push any glyphs`
        : `Pushed a grand total of ${this.glyphsPushed} ${plural} to ${to.name}`
    );
  }
}

export default PushGlyphs;
