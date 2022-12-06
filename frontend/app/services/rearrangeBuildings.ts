import lacuna from 'app/lacuna';
import _ from 'lodash';
import { Matrix } from 'app/interfaces/rearrangeBuildings';
import { int } from 'app/util';
import { types } from '@tlecommunity/client';

type Buildings = types.Body.GetBuildingsResponse['buildings'];
type Arrangement = types.Body.RearrangeBuildingsParams['arrangement'];

class RearrangeBuildingsService {
  async fetchBuildingsMatrix(bodyId: number): Promise<Matrix> {
    const res = await lacuna.body.getBuildings({ body_id: bodyId });
    return this.buildingsToMatrix(res.buildings);
  }

  buildingsToMatrix(buildings: Buildings): Matrix {
    const matrix: Matrix = [];

    _.each(buildings, (building, id) => {
      matrix[building.x] = matrix[building.x] || [];
      matrix[building.x][building.y] = { id: int(id), ...building };
    });

    return matrix;
  }

  rearrangeBuildingsFromMatrix(
    bodyId: number,
    matrix: Matrix
  ): Promise<types.Body.RearrangeBuildingsResponse> {
    return lacuna.body.rearrangeBuildings({
      body_id: bodyId,
      arrangement: this.matrixToRearrangeCall(matrix),
    });
  }

  matrixToRearrangeCall(matrix: Matrix): Arrangement {
    const buildings: Arrangement = [];

    for (let x = -5; x <= 5; x++) {
      if (!matrix[x]) continue;
      for (let y = -5; y <= 5; y++) {
        const b = matrix[x][y];
        if (!b) continue;
        buildings.push({ x: b.x, y: b.y, id: b.id });
      }
    }

    return buildings;
  }
}

export default new RearrangeBuildingsService();
