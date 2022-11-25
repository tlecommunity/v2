import { ServerDate, IntBool } from 'app/interfaces';

export type Target =
  | { body_id: number }
  | { body_name: string }
  | { bookmark: string }
  | { star_id: number }
  | { star_name: string }
  | { x: number; y: number };

export type Paging = {
  page_number: number;
  items_per_page: number;
};

export type Filter = {
  task?: string;
  tag?: string;
};

export type Fleet = {
  task: string;
  id: number;
  quantity: number;
  date_arrives?: ServerDate;
  reason?: { 0: number; 1: string };

  to?: {
    name: string;
    id: number;
    type: string;
    owner: string;
    x: number;
    y: number;
    empire: {
      id: number;
      name: string;
    };
  };

  from?: {
    name: string;
    id: number;
    type: string;
    owner: string;
    x: number;
    y: number;
    empire: {
      id: number;
      name: string;
    };
  };

  details: {
    hold_size: number;
    combat: number;
    efficiency: number;
    speed: number;
    date_started: ServerDate;
    max_occupants: number;
    date_available: ServerDate;
    mark: string;
    berth_level: number;
    can_rename: IntBool;
    name: string;
    stealth: number;
    type: string;
    build_tags: string[];
    can_recall: IntBool;
    payload: string[];
    type_human: string;
    can_scuttle: IntBool;
  };

  earliest_arrival?: {
    month: number;
    day: number;
    hour: number;
    minute: number;
    second: number;
  };
};

export interface SpacePortViewAllFleetsParams {
  building_id: number;
  paging?: Paging;
  filter?: Filter;
  sort?: string;
}

export interface SpacePortViewAllFleetsResponse {
  fleets: Fleet[];
  number_of_fleets: number;
}

export interface SpacePortViewTravellingFleetsParams {
  building_id: number;
  paging?: Paging;
  filter?: Filter;
  sort?: string;
}

export interface SpacePortViewTravellingFleetsResponse {
  travelling: Fleet[];
  number_of_fleets_travelling: number;
  number_of_ships_travelling: number;
}

export interface SpacePortViewAvailableFleetsParams {
  body_id: number;
  target: Target;
  filter?: Filter;
  sort?: string;
}

export interface SpacePortViewAvailableFleetsResponse {
  available: Fleet[];
}

export interface SpacePortViewUnavailableFleetsParams {
  body_id: number;
  target: Target;
  filter?: Filter;
  sort?: string;
}

export interface SpacePortViewUnavailableFleetsResponse {
  unavailable: Fleet[];
}

export interface SpacePortViewOrbitingFleetsParams {
  target: Target;
  filter?: Filter;
  sort?: string;
}

export interface SpacePortViewOrbitingFleetsResponse {
  orbiting: Fleet[];
}

export interface SpacePortViewIncomingFleetsParams {
  target: Target;
  filter?: Filter;
  sort?: string;
}

export interface SpacePortViewIncomingFleetsResponse {
  incoming: Fleet[];
  number_of_incoming_fleets: number;
  number_of_incoming_ships: number;
}

export interface SpacePortSendFleetParams {
  fleet_id: number;
  target: Target;
  quantity: number;
}

export interface SpacePortSendFleetResponse {
  // "id" : "id-goes-here",
  // "quantity" : 1,
  // "task" : "Travelling",
  // "details" {
  //   "name" : "P13",
  //   "mark" : "A3123AB8ED",
  //   "type_human" : "Probe",
  //   "type" : "probe",
  //   "speed" : "1200",
  //   "stealth" : "0",
  //   "combat" : "0",
  //   "hold_size" : "0",
  //   "berth_level" : "1",
  //   "date_started" : "01 31 2010 13:09:05 +0600",
  //   "date_available" : "02 01 2010 10:08:33 +0600",
  //   "max_occupants" : "0",
  //   "payload" : "{}",
  //   "can_scuttle" : "0",
  //   "can_recall" : "0",
  // },
  // "date_arrives" : "02 01 2010 10:08:33 +0600",
  // "from" : {
  //   "id" : "id-goes-here",
  //   "type" : "body",
  //   "name" : "Earth",
  //   "owner" : "Allied",
  //   "empire" : {
  //     "id" : "id-goes-here",
  //     "name" : "Earthlings"
  //   }
  // },
  // "to" : {
  //   "id" : "id-goes-here",
  //   "type" : "star",
  //   "name" : "Sol",
  // }
}
