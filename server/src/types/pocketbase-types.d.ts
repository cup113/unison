/**
* This file was @generated using pocketbase-typegen
*/

import type PocketBase from 'pocketbase'
import type { RecordService } from 'pocketbase'

export enum Collections {
	Authorigins = "_authOrigins",
	Externalauths = "_externalAuths",
	Mfas = "_mfas",
	Otps = "_otps",
	Superusers = "_superusers",
	AppUsage = "appUsage",
	Focus = "focus",
	FocusTodo = "focusTodo",
	Todos = "todos",
	Users = "users",
}

// Alias types for improved usability
export type IsoDateString = string
export type RecordIdString = string
export type HTMLString = string

type ExpandType<T> = unknown extends T
	? T extends unknown
		? { expand?: unknown }
		: { expand: T }
	: { expand: T }

// System fields
export type BaseSystemFields<T = unknown> = {
	id: RecordIdString
	collectionId: string
	collectionName: Collections
} & ExpandType<T>

export type AuthSystemFields<T = unknown> = {
	email: string
	emailVisibility: boolean
	username: string
	verified: boolean
} & BaseSystemFields<T>

// Record types for each collection

export type AuthoriginsRecord = {
	collectionRef: string
	created?: IsoDateString
	fingerprint: string
	id: string
	recordRef: string
	updated?: IsoDateString
}

export type ExternalauthsRecord = {
	collectionRef: string
	created?: IsoDateString
	id: string
	provider: string
	providerId: string
	recordRef: string
	updated?: IsoDateString
}

export type MfasRecord = {
	collectionRef: string
	created?: IsoDateString
	id: string
	method: string
	recordRef: string
	updated?: IsoDateString
}

export type OtpsRecord = {
	collectionRef: string
	created?: IsoDateString
	id: string
	password: string
	recordRef: string
	sentTo?: string
	updated?: IsoDateString
}

export type SuperusersRecord = {
	created?: IsoDateString
	email: string
	emailVisibility?: boolean
	id: string
	password: string
	tokenKey: string
	updated?: IsoDateString
	verified?: boolean
}

export type AppUsageRecord = {
	appName: string
	created?: IsoDateString
	duration: number
	id: string
	start: IsoDateString
	updated?: IsoDateString
	user: RecordIdString
}

export type FocusRecord = {
	created?: IsoDateString
	durationFocus: number
	durationInterrupted?: number
	durationTarget: number
	end: IsoDateString
	id: string
	start: IsoDateString
	updated?: IsoDateString
	user?: RecordIdString
}

export type FocusTodoRecord = {
	created?: IsoDateString
	duration: number
	focus: RecordIdString
	id: string
	progressEnd?: number
	progressStart?: number
	todo: RecordIdString
	updated?: IsoDateString
}

export type TodosRecord = {
	active?: boolean
	archived?: boolean
	category?: string
	created?: IsoDateString
	durationFocus?: number
	estimation?: number
	id: string
	progress?: number
	title: string
	total: number
	updated?: IsoDateString
	user?: RecordIdString
}

export type UsersRecord = {
	avatar?: string
	created?: IsoDateString
	email: string
	emailVisibility?: boolean
	friends?: RecordIdString[]
	id: string
	name?: string
	password: string
	tokenKey: string
	updated?: IsoDateString
	verified?: boolean
}

// Response types include system fields and match responses from the PocketBase API
export type AuthoriginsResponse<Texpand = unknown> = Required<AuthoriginsRecord> & BaseSystemFields<Texpand>
export type ExternalauthsResponse<Texpand = unknown> = Required<ExternalauthsRecord> & BaseSystemFields<Texpand>
export type MfasResponse<Texpand = unknown> = Required<MfasRecord> & BaseSystemFields<Texpand>
export type OtpsResponse<Texpand = unknown> = Required<OtpsRecord> & BaseSystemFields<Texpand>
export type SuperusersResponse<Texpand = unknown> = Required<SuperusersRecord> & AuthSystemFields<Texpand>
export type AppUsageResponse<Texpand = unknown> = Required<AppUsageRecord> & BaseSystemFields<Texpand>
export type FocusResponse<Texpand = unknown> = Required<FocusRecord> & BaseSystemFields<Texpand>
export type FocusTodoResponse<Texpand = unknown> = Required<FocusTodoRecord> & BaseSystemFields<Texpand>
export type TodosResponse<Texpand = unknown> = Required<TodosRecord> & BaseSystemFields<Texpand>
export type UsersResponse<Texpand = unknown> = Required<UsersRecord> & AuthSystemFields<Texpand>

// Types containing all Records and Responses, useful for creating typing helper functions

export type CollectionRecords = {
	_authOrigins: AuthoriginsRecord
	_externalAuths: ExternalauthsRecord
	_mfas: MfasRecord
	_otps: OtpsRecord
	_superusers: SuperusersRecord
	appUsage: AppUsageRecord
	focus: FocusRecord
	focusTodo: FocusTodoRecord
	todos: TodosRecord
	users: UsersRecord
}

export type CollectionResponses = {
	_authOrigins: AuthoriginsResponse
	_externalAuths: ExternalauthsResponse
	_mfas: MfasResponse
	_otps: OtpsResponse
	_superusers: SuperusersResponse
	appUsage: AppUsageResponse
	focus: FocusResponse
	focusTodo: FocusTodoResponse
	todos: TodosResponse
	users: UsersResponse
}

// Type for usage with type asserted PocketBase instance
// https://github.com/pocketbase/js-sdk#specify-typescript-definitions

export type TypedPocketBase = PocketBase & {
	collection(idOrName: '_authOrigins'): RecordService<AuthoriginsResponse>
	collection(idOrName: '_externalAuths'): RecordService<ExternalauthsResponse>
	collection(idOrName: '_mfas'): RecordService<MfasResponse>
	collection(idOrName: '_otps'): RecordService<OtpsResponse>
	collection(idOrName: '_superusers'): RecordService<SuperusersResponse>
	collection(idOrName: 'appUsage'): RecordService<AppUsageResponse>
	collection(idOrName: 'focus'): RecordService<FocusResponse>
	collection(idOrName: 'focusTodo'): RecordService<FocusTodoResponse>
	collection(idOrName: 'todos'): RecordService<TodosResponse>
	collection(idOrName: 'users'): RecordService<UsersResponse>
}
